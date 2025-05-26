import {
  CognitoIdentityProviderClient,
  AdminCreateUserCommand,
  AdminSetUserPasswordCommand,
} from "@aws-sdk/client-cognito-identity-provider";
// import { fromIni } from "@aws-sdk/credential-provider-ini";
// const client = new CognitoIdentityProviderClient({
//   region: "us-east-1",
//   credentials: fromIni({ profile: "fiap-aws-sso" }),
// });

const client = new CognitoIdentityProviderClient({});

const USER_POOL_ID = process.env.USER_POOL_ID!;

export const handler = async (event: any) => {
  const cpf = event.cpf || "12345678901"; // ou pegue de event.body

  try {
    const command = new AdminCreateUserCommand({
      UserPoolId: USER_POOL_ID,
      Username: cpf,
      UserAttributes: [
        {
          Name: "custom:cpf",
          Value: cpf,
        },
        {
          Name: "email_verified",
          Value: "true",
        },
        {
          Name: "email",
          Value: `${cpf}@exemplo.com`,
        },
      ],
      DesiredDeliveryMediums: [], // evita envio de e-mail
      MessageAction: "SUPPRESS", // suprime e-mail automático
    });
    

    const result = await client.send(command);

    const passwordResult = await client.send(
      new AdminSetUserPasswordCommand({
        UserPoolId: USER_POOL_ID,
        Username: cpf,
        Password: "SenhaForteOculta123!",
        Permanent: true,
      })
    );

    const response = {
      statusCode: 201,
      body: JSON.stringify({
        message: "Usuário criado com sucesso",
        user: result.User?.Username,
        isPasswordSet: passwordResult.$metadata.httpStatusCode === 200,
      }),
    }

    console.log(response);

    return response;
  } catch (err: any) {
    const response = {
      statusCode: 500,
      body: JSON.stringify({
        error: "Erro ao criar usuário",
        details: err.message,
      }),
    }

    console.log(response);

    return response;
  }
};