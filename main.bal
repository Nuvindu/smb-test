import ballerina/io;
import ballerina/log;
import nuvindu/smb;

configurable string kerberosHost = ?;
configurable string kerberosUser = ?;
configurable string kerberosPassword = ?;
configurable string kerberosDomain = ?;
configurable string kerberosShare = ?;
configurable string kerberosConfigFile = ?;

public function main() returns error? {
    smb:Client|error kerberosClient = new ({
        host: kerberosHost,
        port: 445,
        auth: {
            credentials: {
                username: kerberosUser,
                password: kerberosPassword,
                domain: kerberosDomain
            },
            kerberosConfig: {
                principal: kerberosUser + "@" + kerberosDomain,
                configFile: kerberosConfigFile
            }
        },
        share: kerberosShare
    });

    if kerberosClient is error {
        log:printError(kerberosClient.message(), kerberosClient);
        io:println("Error occurred while creating the Kerberos authenticated SMB client: " +
            kerberosClient.message());
        return error (kerberosClient.message());
    }

    smb:FileInfo[]|error listResult = kerberosClient->list("/");
    io:println(listResult);
 
    string testFileName = "/kerberos_test_file5.txt";
    string testContent = "Hello from Kerberos authenticated client!";
    error? writeResult = kerberosClient->putText(testFileName, testContent);

    boolean|error existsResult = kerberosClient->exists(testFileName);

    string|error readResult = kerberosClient->getText(testFileName);
    io:println(readResult);

}
