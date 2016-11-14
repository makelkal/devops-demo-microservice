*** Settings ***
Library         OperatingSystem
Library         Collections
Library         String
Library         RequestsLibrary

Suite Setup     Initialize Session
Suite Teardown  Delete All Sessions

*** Variables ***
${SERVICE_URL}          http://localhost:9002
${CATALOG_ID}          1


*** Test Cases ***
Get a catalog item
  [Documentation]  Reads the defaut customer information from the database
  Given catalog item exists at the database
  When I get the catalog item through REST API
  Then catalog item name should be "iPod"
   And catalog item price should be "42.0"

Add a catalog item
  [Documentation]  Adds new catalog item into database
  ...              and then reads the newly created entry from the database
  [Setup]  Get JSON Template  catalog.json
  Given catalog item name is "Titan"
   And catalog item price is "69.0"
  When I add the catalog item through REST API
   And I get the catalog item through REST API
  Then catalog item name should be "Titan"
   And catalog item price should be "69.0"

Delete a catalog item
  [Documentation]  Deletes catalog item from database
  [Setup]  Get JSON Template  catalog.json
  Given catalog item name is "Titan"
   And catalog item price is "69.0"
   And I add the catalog item through REST API
  When I delete the catalog item through REST API
  Then catalog item should not exist in the database

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

I get the catalog item through REST API  [Arguments]  ${catalog_id}=${CATALOG_ID}
    [Documentation]  Reads the catalog id from the database. The default value is catalog id 1
    ${result}=  Get JSON data  /catalog  ${catalog_id}
    Set Test Variable  ${JSON_CATALOG}  ${result}
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
    Log  ${resp.content}
    ${actual}=  To Json  ${resp.content}
    Log  ${actual}
    [Return]  ${actual}

catalog item exists at the database
    Log  ""

catalog item name should be "${catalog_name}"
    Log  ${JSON_catalog['name']}
    Should Be Equal As Strings  ${JSON_catalog['name']}  ${catalog_name}

catalog item price should be "${catalog_price}"
    Log  ${JSON_catalog['price']}
    Should Be Equal As Numbers  ${JSON_catalog['price']}  ${catalog_price}

catalog item name is "${name}"
    Set Test Variable  ${CATALOG_ITEM}  ${name}

catalog item price is "${price}"
    Set Test Variable  ${CATALOG_PRICE}  ${price}


I add the catalog item through REST API
    [Documentation]  Adds a new catalog item to the database. Stores the newly created catalog id
    ...              to a test variable CATALOG_ID
    ${data}=  Replace Variables  ${TEMPLATE}
    ${result}=  Post JSON data  /catalog  ${data}
    Set Test Variable  ${CATALOG_ID}  ${result['id']}

I delete the catalog item through REST API  [Arguments]  ${id}=${CATALOG_ID}
    [Documentation]  Deleted catalog item from the database.
    ${result}=  Delete JSON data  /catalog  ${id}


Delete JSON data  [Arguments]  ${uri}  ${id}
  [Documentation]  Removes the object identfied by id through REST api
  Log  ${id}
  ${resp}=  Delete Request  appsrv  ${uri}/${id}
  Should Be Equal As Strings  ${resp.status_code}  204

catalog item should not exist in the database
  ${response} =  Run Keyword And Return Status  I get the catalog item through REST API
  Should Be Equal  ${response}  ${FALSE}


