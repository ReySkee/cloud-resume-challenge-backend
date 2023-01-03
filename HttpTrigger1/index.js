require("dotenv").config();

const {
  TableClient,
  AzureNamedKeyCredential,
} = require("@azure/data-tables");
const endpoint = process.env.ENDPOINT;
const credential = new AzureNamedKeyCredential(
  process.env.ACCOUNT_NAME,
  process.env.ACCOUNT_KEY
);

const tableClient = new TableClient(
  endpoint,
  process.env.TABLE_NAME,
  credential
);

module.exports = async function (context, req) {
  context.log("JavaScript HTTP trigger function processed a request.");

  // Makes sure the row exist
  const initialTask = {
    partitionKey: "1",
    rowKey: "1"
  };
  await tableClient.upsertEntity(initialTask);

  // Get the current count from the table
  const oldNumber = await tableClient
    .getEntity("1", "1")
    .then((result) => result.count)
    .catch((error) => {
      context.res = {
        status: 500,
        body: error,
      };
      return;
    });

  if (oldNumber !== undefined) {
    // Increment the count
    const newNumber = oldNumber + 1;

    // Update the count in the table
    const task = {
      partitionKey: "1",
      rowKey: "1",
      count: newNumber,
    };
    await tableClient.upsertEntity(task);

    // Get the updated count from the table
    const newCount = await tableClient
      .getEntity("1", "1")
      .then((result) => result.count)
      .catch((error) => {
        context.res = {
          status: 500,
          body: error,
        };
        return;
      });

    if (newCount !== undefined) {
      // Return the count in the response
      const responseMessage = { count: newCount };
      context.res = {
        status: 200 /* Defaults to 200 */,
        body: responseMessage,
      };
    }
  }
};
