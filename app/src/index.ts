import { CognitoIdentityProviderClient, AdminGetUserCommand } from "@aws-sdk/client-cognito-identity-provider";
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

const client = new CognitoIdentityProviderClient({});

const USER_POOL_ID = process.env.USER_POOL_ID!;

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  let body: any = {};

  try {
    // Se vier string (API Gateway), parse
    if (typeof event.body === "string") {
      body = JSON.parse(event.body);
    } 
    // Se vier como objeto (invocação direta), usa direto
    else if (typeof event.body === "object") {
      body = event.body;
    } 
    // Se for nulo, usa o próprio event (caso do test manual)
    else if (!event.body && (event as any).cpf) {
      body = event;
    }
  } catch {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "JSON inválido no corpo da requisição" }),
    };
  }

  const cpf = body?.cpf;

  if (!cpf) {
    return { statusCode: 400, body: JSON.stringify({ error: "CPF é obrigatório" }) };
  }

  try {
    const command = new AdminGetUserCommand({
      Username: cpf,
      UserPoolId: USER_POOL_ID,
    });

    const result = await client.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify({
        cpf,
        status: result.UserStatus,
        enabled: result.Enabled,
        attributes: result.UserAttributes,
      }),
    };
  } catch (err: any) {
    return {
      statusCode: 404,
      body: JSON.stringify({ error: "Usuário não encontrado", details: err.message }),
    };
  }
};