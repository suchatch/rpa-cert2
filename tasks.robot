*** Settings ***
Documentation       Create Order Process
Library            RPA.Browser.Selenium    auto_close=${FALSE}
Library            RPA.HTTP
Library            RPA.Tables
Library            RPA.PDF
Library            RPA.Archive
Library            RPA.FileSystem

*** Variables ***
${pdf_lists}
${img_lists}

*** Tasks ***
Create Order Process
    Open the robot order website
    Download file csv
    Fill the form using the data from the CSV file
    Creates ZIP archive of the receipts and the images.
    [Teardown]    Close the browser

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
	Click Element    xpath=//button[@class='btn btn-dark']

Download file csv
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill and submit the form for order your robot
    [Arguments]    ${rs}
    Select From List By Index    id:head    ${rs}[Head]
    Select Radio Button    body    ${rs}[Body]
    Input Text    xpath=//input[@placeholder='Enter the part number for the legs']    ${rs}[Legs]
    Input Text    id:address    ${rs}[Address]
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image
    Wait Until Element Is Visible    xpath=//img[@alt='Head']    5
    Wait Until Element Is Visible    xpath=//img[@alt='Body']    5
    Wait Until Element Is Visible    xpath=//img[@alt='Legs']    5
    Wait Until Keyword Succeeds    3x    1s    Click Order Robot
    
Click Order Robot
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt    2

Fill the form using the data from the CSV file
    ${orders}=    Read table from CSV    orders.csv
    Log   Found columns: ${orders.columns}
    FOR    ${rs}    IN    @{orders}
        Fill and submit the form for order your robot    ${rs}
        Generate PDF File     ${rs}
        Click Button    id:order-another
        Click Element    xpath=//button[@class='btn btn-dark']
        Log    ${rs}
    END

Generate PDF File
    [Arguments]    ${row}
    ${order_html}=     Get Element Attribute    id:receipt    outerHTML
    Capture Picture    ${row} 
    Html To Pdf    ${order_html}    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}${row}[Order number].png
    Set Convert Settings  line_margin=3
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}${row}[Order number].pdf    True
    
Capture Picture
    [Arguments]    ${row}
    Screenshot      id:robot-preview    ${OUTPUT_DIR}${/}${row}[Order number].png    

Creates ZIP archive of the receipts and the images.
    Archive Folder With Zip    ${OUTPUT_DIR}    RobotsReady.zip    True
    # Create File    RobotsReady.zip    overwrite=${True}
    # Add To Archive    ${OUTPUT_DIR}${/}1.pdf    RobotsReady.zip

Close the browser
    Close Browser

