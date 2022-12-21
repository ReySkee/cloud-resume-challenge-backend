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

  const oldNumber = await tableClient.getEntity("1", "1").catch((error) => {
    // handle any errors
  });

  const newNumber = oldNumber.count + 1;

  const task = {
    partitionKey: "1",
    rowKey: "1",
    count: newNumber,
  };

  const add = await tableClient.updateEntity(task, "Replace");

  const newCount = await tableClient.getEntity("1", "1").catch((error) => {
    // handle any errors
  });

  // result contains the entity
  // Entity create
  const name = req.query.name || (req.body && req.body.name);
  const responseMessage = { count: newCount.count };

  context.res = {
    status: 200 /* Defaults to 200 */,
    body: responseMessage,
  };
};
