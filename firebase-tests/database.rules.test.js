const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  equalTo,
  get,
  orderByChild,
  query,
  ref,
  set,
  update,
} = require("firebase/database");

const projectId = "demo-unimas-foodhub";
const rules = fs.readFileSync(
  path.join(__dirname, "../database.rules.json"),
  "utf8",
);
let testEnvironment;

test.before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId,
    database: {
      host: "127.0.0.1",
      port: 9000,
      rules,
    },
  });
});

test.beforeEach(async () => {
  await testEnvironment.clearDatabase();
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const database = context.database();
    await Promise.all([
      set(ref(database, "users/customer-a"), {
        name: "Customer A",
        email: "customer-a@example.test",
        phone: "000",
        role: "customer",
        createdAt: 1,
      }),
      set(ref(database, "users/customer-b"), {
        name: "Customer B",
        email: "customer-b@example.test",
        phone: "000",
        role: "customer",
        createdAt: 1,
      }),
      set(ref(database, "sellers/seller-a"), {
        stallName: "Stall A",
        ownerName: "Seller A",
        email: "seller-a@example.test",
        phone: "000",
        description: "Test stall",
        isOpen: true,
        cuisineType: "Malay",
        rating: 0,
        createdAt: 1,
        role: "seller",
      }),
      set(ref(database, "menuItems/seller-a/item-a"), {
        stallName: "Stall A",
        name: "Test meal",
        description: "Test item",
        price: 10,
        category: "Rice",
        isAvailable: true,
        isPopular: false,
        prepTime: 15,
        calories: 0,
        createdAt: 1,
      }),
      set(ref(database, "orders/order-a"), {
        customerId: "customer-a",
        customerName: "Customer A",
        sellerId: "seller-a",
        stallName: "Stall A",
        status: "pending",
        totalAmount: 10,
        createdAt: 1,
        pickupCode: "FH1234",
        items: {
          "item-a": {
            name: "Test meal",
            price: 10,
            quantity: 1,
            subtotal: 10,
          },
        },
      }),
      set(ref(database, "orders/order-b"), {
        customerId: "customer-b",
        customerName: "Customer B",
        sellerId: "seller-a",
        stallName: "Stall A",
        status: "pending",
        totalAmount: 10,
        createdAt: 2,
        pickupCode: "FH5678",
        items: {
          "item-a": {
            name: "Test meal",
            price: 10,
            quantity: 1,
            subtotal: 10,
          },
        },
      }),
    ]);
  });
});

test.after(async () => {
  await testEnvironment.cleanup();
});

test("requires authentication for public stall and menu reads", async () => {
  const guestDatabase = testEnvironment.unauthenticatedContext().database();
  const customerDatabase = testEnvironment
    .authenticatedContext("customer-a")
    .database();

  await assertFails(get(ref(guestDatabase, "sellers")));
  await assertSucceeds(get(ref(customerDatabase, "sellers")));
  await assertSucceeds(get(ref(customerDatabase, "menuItems")));
});

test("keeps customer profiles private to their owner", async () => {
  const customerDatabase = testEnvironment
    .authenticatedContext("customer-a")
    .database();

  await assertSucceeds(get(ref(customerDatabase, "users/customer-a")));
  await assertFails(get(ref(customerDatabase, "users/customer-b")));
});

test("limits order queries and permits only validated customer orders", async () => {
  const customerDatabase = testEnvironment
    .authenticatedContext("customer-a")
    .database();
  const sellerDatabase = testEnvironment
    .authenticatedContext("seller-a")
    .database();

  const customerOrders = await assertSucceeds(
    get(
      query(
        ref(customerDatabase, "orders"),
        orderByChild("customerId"),
        equalTo("customer-a"),
      ),
    ),
  );
  assert.deepEqual(Object.keys(customerOrders.val()), ["order-a"]);

  const sellerOrders = await assertSucceeds(
    get(
      query(
        ref(sellerDatabase, "orders"),
        orderByChild("sellerId"),
        equalTo("seller-a"),
      ),
    ),
  );
  assert.equal(Object.keys(sellerOrders.val()).length, 2);

  await assertFails(get(ref(customerDatabase, "orders")));
  await assertFails(get(ref(customerDatabase, "orders/order-b")));
  await assertSucceeds(
    set(ref(customerDatabase, "orders/order-new"), {
      customerId: "customer-a",
      customerName: "Customer A",
      sellerId: "seller-a",
      stallName: "Stall A",
      status: "pending",
      totalAmount: 10,
      createdAt: 3,
      pickupCode: "FH9012",
      items: {
        "item-a": {
          name: "Test meal",
          price: 10,
          quantity: 1,
          subtotal: 10,
        },
      },
    }),
  );
  await assertFails(
    set(ref(customerDatabase, "orders/order-invalid"), {
      customerId: "customer-a",
      customerName: "Customer A",
      sellerId: "seller-a",
      stallName: "Stall A",
      status: "pending",
      totalAmount: 11,
      createdAt: 3,
      pickupCode: "FH9013",
      items: {
        "item-a": {
          name: "Test meal",
          price: 11,
          quantity: 1,
          subtotal: 11,
        },
      },
    }),
  );
  await assertFails(
    set(ref(customerDatabase, "orders/order-for-other"), {
      customerId: "customer-b",
      customerName: "Customer B",
      sellerId: "seller-a",
      stallName: "Stall A",
      status: "pending",
      totalAmount: 10,
      createdAt: 3,
      pickupCode: "FH9014",
      items: {
        "item-a": {
          name: "Test meal",
          price: 10,
          quantity: 1,
          subtotal: 10,
        },
      },
    }),
  );
});

test("allows pending cancellation only to its customer and status progression to its seller", async () => {
  const customerDatabase = testEnvironment
    .authenticatedContext("customer-a")
    .database();
  const sellerDatabase = testEnvironment
    .authenticatedContext("seller-a")
    .database();

  await assertSucceeds(set(ref(customerDatabase, "orders/order-a/status"), "cancelled"));
  await assertFails(set(ref(customerDatabase, "orders/order-b/status"), "cancelled"));
  await assertFails(set(ref(customerDatabase, "orders/order-a/status"), "preparing"));
  await assertSucceeds(set(ref(sellerDatabase, "orders/order-b/status"), "confirmed"));
});

test("lets only the owning seller manage menu items and customers rate completed orders once", async () => {
  const customerDatabase = testEnvironment
    .authenticatedContext("customer-a")
    .database();
  const ownerDatabase = testEnvironment
    .authenticatedContext("seller-a")
    .database();
  const otherSellerDatabase = testEnvironment
    .authenticatedContext("seller-b")
    .database();

  await assertSucceeds(
    set(
      ref(ownerDatabase, "menuItems/seller-a/item-a/isAvailable"),
      false,
    ),
  );
  await assertFails(
    set(
      ref(otherSellerDatabase, "menuItems/seller-a/item-a/isAvailable"),
      false,
    ),
  );
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await set(ref(context.database(), "orders/order-a/status"), "completed");
  });
  await assertSucceeds(
    update(ref(customerDatabase, "orders/order-a"), {
      rating: 5,
      comment: "Great meal",
    }),
  );
  await assertFails(set(ref(customerDatabase, "orders/order-a/rating"), 4));
  await assertFails(set(ref(customerDatabase, "orders/order-b/rating"), 5));
});

test("preserves ratings when a customer submits no written comment", async () => {
  const customerDatabase = testEnvironment
    .authenticatedContext("customer-a")
    .database();

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await set(ref(context.database(), "orders/order-a/status"), "completed");
  });

  await assertSucceeds(
    update(ref(customerDatabase, "orders/order-a"), { rating: 4 }),
  );
  await assertFails(
    update(ref(customerDatabase, "orders/order-a"), { rating: 5 }),
  );

  const savedOrder = await get(ref(customerDatabase, "orders/order-a"));
  assert.equal(savedOrder.val().rating, 4);
  assert.equal(savedOrder.val().comment, undefined);
});

test("publishes a completed order rating without exposing the private order", async () => {
  const customerDatabase = testEnvironment
    .authenticatedContext("customer-a")
    .database();
  const otherCustomerDatabase = testEnvironment
    .authenticatedContext("customer-b")
    .database();
  const guestDatabase = testEnvironment.unauthenticatedContext().database();

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await set(ref(context.database(), "orders/order-a/status"), "completed");
  });

  await assertSucceeds(
    update(ref(customerDatabase, "orders/order-a"), { rating: 5 }),
  );
  await assertSucceeds(
    set(ref(customerDatabase, "sellers/seller-a/reviews/order-a"), {
      customerName: "Customer",
      rating: 5,
      createdAt: 1,
    }),
  );
  await assertSucceeds(
    get(ref(otherCustomerDatabase, "sellers/seller-a/reviews/order-a")),
  );
  await assertFails(get(ref(otherCustomerDatabase, "orders/order-a")));
  await assertFails(get(ref(guestDatabase, "sellers/seller-a/reviews/order-a")));
  await assertFails(
    set(ref(otherCustomerDatabase, "sellers/seller-a/reviews/order-b"), {
      customerName: "Customer",
      rating: 1,
      createdAt: 1,
    }),
  );
});
