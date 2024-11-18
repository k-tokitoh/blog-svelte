import { CloudFrontClient, ListInvalidationsCommand, CreateInvalidationCommand } from "@aws-sdk/client-cloudfront";

export const handler = async (_event) => {
  const client = new CloudFrontClient()

  // 1回のデプロイで1回invalidateされれば十分
  // lambdaはオブジェクト作成のイベントでトリガーされるため、現在進行中のinvalidationがない場合のみcreateする
  const listInput = {
    DistributionId: "${cloudfront_distribution_id}",
  };
  const listCommand = new ListInvalidationsCommand(listInput)
  const listRes = await client.send(listCommand)
  const inProgress = listRes.InvalidationList.Items.some(item => item.Status === 'InProgress')
  console.info({listRes}, listRes.InvalidationList.Items)

  if (inProgress) return;

  // invalidate
  const createInput = {
    DistributionId: "${cloudfront_distribution_id}",
    InvalidationBatch: {
      CallerReference: String(Date.now()),
      Paths: {
        Items: ["/*"],
        Quantity: 1
      }
    }
  }
  const createCommand = new CreateInvalidationCommand(createInput)
  const createRes = await client.send(createCommand)
  console.info({ createRes })
};
