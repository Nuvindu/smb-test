import ballerina/io;
import nuvindu/smb;
import ballerina/log;

configurable string kerberosHost = ?;
configurable string port = ?;
configurable string kerberosUser = ?;
configurable string kerberosPassword = ?;
configurable string kerberosDomain = ?;
configurable string kerberosShare = ?;
configurable string kerberosConfigFile = ?;

public function main() returns error? {
    smb:Client|error ntlmClient = new ({
        host: kerberosHost,
        port,
        auth: {
            credentials: {
                username: kerberosUser,
                password: kerberosPassword,
                domain: kerberosDomain
            }
        },
        share: kerberosShare
    });


    if ntlmClient is error {
        log:printError(ntlmClient.message(), ntlmClient);
        io:println("Error occurred while creating the Kerberos authenticated SMB client: " +
            ntlmClient.message());
        return error (ntlmClient.message());
    }
    log:printInfo("client intialized");
    smb:FileInfo[]|error listResult = ntlmClient->list("/");
    if listResult is error {
        log:printError(listResult.message(), listResult);
        return error (listResult.message());
    }
    log:printInfo(listResult.toString());
    io:println(listResult);
 
    string testFileName = "/ntlm_test_file5.txt";
    string testContent = "Hello from NTLM authenticated client!";
    error? writeResult = ntlmClient->putText(testFileName, testContent);

    boolean|error existsResult = ntlmClient->exists(testFileName);

    string|error readResult = ntlmClient->getText(testFileName);
    io:println(readResult);

}
