*** Settings ***
Library         OperatingSystem
Library         Collections
Library         String
Library         RequestsLibrary

Suite Setup     Initialize Session
Suite Teardown  Delete All Sessions

*** Variables ***
${SERVICE_URL}          http://localhost:9000
${CUSTOMER_ID}          1

*** Test Cases ***
Get a customer
  [Documentation]  Reads the defaut customer information from the database
  Given Customer exists at the database
  When I get the customer through REST API
  Then customer name should be "Wolff"
   and firstname should be "Eberhard"
   and email should be "eberhard.wolff@gmail.com"
   and street should be "Unter den Linden"
   and city should be "Berlin"

Add a new customer
  [Documentation]  Adds a new customer to the database
  ...              and then reads the newly created entry from the database
  [Setup]  Get JSON Template  customer.json
  Given customer name is "Selanne"
    and firstname is "Teemu"
    and email is "teemu.selanne@gmail.com"
    and street is "Madre Selva LN"
    and city is "San Diego"
  When I add the customer through REST API
   and I get the Customer through REST API
  Then customer name should be "Selanne"
   and firstname should be "Teemu"
   and email should be "teemu.selanne@gmail.com"
   and street should be "Madre Selva LN"
   and city should be "San Diego"

Delete a customer
  [Documentation]  Deletes customer from the database
  [Setup]  Get JSON Template  customer.json
  Given customer name is "Kurri"
   And firstname is "Jari"
   And email is "teemu.selanne@gmail.com"
   And street is "East Street 1"
   And city is "New York"
   And I add the customer through REST API
   and I get the Customer through REST API
  When I delete the customer through REST API
  Then customer should not exist in the database

*** Keywords ***
Get JSON Template  [Arguments]  ${form}
  [Documentation]  Reads the json template. Template name is given as an argument.
  ...              Template should reside at the same directory as the test case.
  ${json}=  Get File  ${CURDIR}${/}${form}  encoding=utf-8
  Set Test Variable  ${TEMPLATE}  ${json}

Initialize Session
  [Documentation]  Creates context for REST API calls.
  Set Log Level         TRACE
  ${headers}=  Create Dictionary  Content-type=application/json  Accept=*/*  Accept-language=en-US,en;fi  Cache-control=no-cache
  Set Suite Variable  ${HEADERS}  ${headers}
  Create Session  appsrv  ${SERVICE_URL}  headers=${headers}

I get the Customer through REST API  [Arguments]  ${cust_id}=${CUSTOMER_ID}
  [Documentation]  Reads the customer from the database. The default value is customer id 1
  ${result}=  Get JSON data  /customer  ${cust_id}
  Set Test Variable  ${JSON_CUSTOMER}  ${result}
  [Return]  ${result}

Get JSON data  [Arguments]   ${uri}  ${cust_id}
  [Documentation]  Reads the data as JSON object through REST API. The service URI is given as an argument.
  ...              Customer id is given as second argument
  ...              Returns also the received JSON object
  ${resp}=  Get Request  appsrv  ${uri}/${cust_id}
  Should Be Equal As Strings  ${resp.status_code}  200
  ${actual}=  To Json  ${resp.content}
  Log  ${resp.content}
  [Return]  ${actual}

Post JSON data  [Arguments]  ${uri}  ${data}
  [Documentation]  Posts Customer data through REST API.
  Log  ${data}
  ${resp}=  Post Request  appsrv  ${uri}  data=${data}
  Log  ${resp.text}
  Should Be Equal As Strings  ${resp.status_code}  201
  ${actual}=  To Json  ${resp.content}
  Log  ${actual}
  [Return]  ${actual}

Put JSON data  [Arguments]  ${uri}  ${data}
  [Documentation]  Update existing data through REST api
  Log  ${data}
  ${resp}=  Put Request  appsrv  ${uri}  data=${data}
  Should Be Equal As Strings  ${resp.status_code}  200
  ${actual}=  To Json  ${resp.content}
  Log  ${actual}
  [Return]  ${actual}

Customer exists at the database
    Log  ""

Customer name is "${name}"
  Set Test Variable  ${NAME}  ${name}

Firstname is "${name}"
  Set Test Variable  ${FIRSTNAME}  ${name}

Email is "${email}"
  Set Test Variable  ${EMAIL}  ${email}

Street is "${street}"
  Set Test Variable  ${STREET}  ${street}

City is "${city}"
  Set Test Variable  ${CITY}  ${city}

Customer name should be "${name}"
  Should Be Equal As Strings  ${JSON_CUSTOMER['name']}  ${name}

Firstname should be "${name}"
    Should Be Equal As Strings  ${JSON_CUSTOMER['firstname']}  ${name}

Email should be "${email}"
    Should Be Equal As Strings  ${JSON_CUSTOMER['email']}  ${email}

Street should be "${street}"
    Should Be Equal As Strings  ${JSON_CUSTOMER['street']}  ${street}

City should be "${city}"
    Should Be Equal As Strings  ${JSON_CUSTOMER['city']}  ${city}

I delete the customer through REST API  [Arguments]  ${id}=${CUSTOMER_ID}
    [Documentation]  Deleted catalog item from the database.
    ${result}=  Delete JSON data  /customer  ${id}


Delete JSON data  [Arguments]  ${uri}  ${id}
  [Documentation]  Removes the object identfied by id through REST api
  Log  ${id}
  ${resp}=  Delete Request  appsrv  ${uri}/${id}
  Should Be Equal As Strings  ${resp.status_code}  204

customer should not exist in the database
  ${response} =  Run Keyword And Return Status  I get the Customer through REST API
  Should Be Equal  ${response}  ${FALSE}

I Add The Customer Through REST API
   [Documentation]  Adds a new customer to the database. Stores the newly created customer id
   ...              to a test variable CUSTOMER_ID
   ${data}=  Replace Variables  ${TEMPLATE}
   ${result}=  Post JSON data  /customer  ${data}
   Set Test Variable  ${CUSTOMER_ID}  ${result['id']}
