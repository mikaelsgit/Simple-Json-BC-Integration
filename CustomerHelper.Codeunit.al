codeunit 60000 "Customer Helper"
{
    procedure ExportCustomer(var Customer: Record "Customer")
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;


        jObject: JsonObject;
        jArray: JsonArray;
        jResultObject: JsonObject;
        
        
        jText: Text;
        responseText: Text;
        responseJson: JsonObject;
    begin
        // Create request payload, simple case of a single json object
        jObject.Add('no', Customer."No."); // key -> value
        jObject.Add('name', Customer.Name); // key -> value

        // Object created, convert to text
        jObject.WriteTo(jText);

        // Write text to Content (json formatted)
        Content.WriteFrom(jText);

        // Diff between request headers and content headers!
        // The content of the client request; which will NOT be changed across multiple requests to the same server -  will be part of HEADER e.g. credentials, 
        // others which are frequently changed per request will be part of BODY. 

        // Add Request Header
        Client.DefaultRequestHeaders.Add('x-api-key', 'ySQu6QGKD78IIMWchzdKp7i1h69UQCCO6ZO8h8Bm');
        // If-Match: <etag_value>
        Client.DefaultRequestHeaders.Add('Authorization', CreateBasicAuthHeader('user', 'password'));
        Client.DefaultRequestHeaders.Add('Authorization', 'Bearer <insertAccessTokenHere>');
        // https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html


        // Add Content Headers
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');      // Always include if you have a payload
        Headers.Add('Content-Length', Format(StrLen(jText)));

        // Prepare Request
        Request.Content := Content; // do not modify content after this
        Request.SetRequestUri('https://kl2lgdpba1.execute-api.eu-north-1.amazonaws.com/dev/customer');
        Request.Method := 'POST';

        // Send Request
        if not Client.Send(Request, Response) then
            Error('Request failed');

        // Check Response code
        if not Response.IsSuccessStatusCode then
            Error('Error: %1, Code: %2', Response.ReasonPhrase, Response.HttpStatusCode);

        // Read Response
        Response.Content().ReadAs(responseText); // Read content into text, this is json, can be read into jobject

        // Read to jObject
        if not jResultObject.ReadFrom(responseText) then
            Error('Faulty JSON');

        Message(responseText);
    end;

    procedure GetRandomData()
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;
        jObject: JsonObject;
        jResultObject: JsonObject;
        jText: Text;
        responseText: Text;
        responseJson: JsonObject;
    begin
        Client.DefaultRequestHeaders.Add('Authorization', CreateBasicAuthHeader('user', 'password')); //Request Header

        // Add Headers
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json'); // Content Header dont add content-type for get but yeah

        Request.SetRequestUri('http://qvm9l.mocklab.io/json/1');
        Request.Method := 'GET';

        // Send Request
        if not Client.Send(Request, Response) then
            Error('Request failed');

        // Check Response code
        if not Response.IsSuccessStatusCode then
            Error('Error: %1, Code: %2', Response.ReasonPhrase, Response.HttpStatusCode);

        // Read Response
        Response.Content().ReadAs(responseText); // Read content into text, this is json, can be read into jobject

        if not jObject.ReadFrom(responseText) then
            Error('stonks not json object frend!!!');

        Message(responseText);

    end;

    procedure CreateBasicAuthHeader(UserName: Text[50]; Password: Text[50]) AuthString: Text;
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        AuthString := StrSubstNo('%1:%2', UserName, Password);
        AuthString := Base64Convert.ToBase64(AuthString);
        AuthString := StrSubstNo('Basic %1', AuthString);

        exit(AuthString);
    end;

    procedure GetJsonValueAsText(var JsonObject: JsonObject; Property: Text) Value: Text
    var
        JsonValue: JsonValue;
    begin
        if not GetJsonValue(JsonObject, Property, JsonValue) then
            exit;

        Value := JsonValue.AsText();
    end;

    procedure GetJsonValue(var JsonObject: JsonObject; Property: Text; var JsonValue: JsonValue): Boolean
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(Property, JsonToken) then
            exit;

        JsonValue := JsonToken.AsValue();
        exit(true)
    end;
}