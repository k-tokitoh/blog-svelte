import { CloudFrontClient, CreateInvalidationCommand } from "@aws-sdk/client-cloudfront";

export const handler = async (_event) => {
  const client = new CloudFrontClient()
  const input = {
    DistributionId: "${cloudfront_distribution_id}",
    InvalidationBatch: {

      CallerReference: String(Date.now()),
      Paths: {
        Items: ["/*"],
        Quantity: 1
      }
    }
  }
  const command = new CreateInvalidationCommand(input)
  const res = await client.send(command)
  console.log({ res })
};
