*** Settings ***
Library    Browser
Library    String
Library    OperatingSystem
Library    RequestsLibrary

*** Variables ***
${BROWSER}            chromium
${HEADLESS}           ${False}
${SITE_SERVE_REST}    https://front.serverest.dev/login

*** Keywords ***
Abrir o navegador
    [Documentation]    Abre navegador com tracing e video
    ${DIR_BASE}    Set Variable    ${CURDIR}/../evidences
    Create Directory    ${DIR_BASE}/traces
    Create Directory    ${DIR_BASE}/videos
    Set Test Variable    ${DIR_BASE}
    ${NOME_CENARIO}    Replace String    ${TEST NAME}    ${SPACE}    _
    Set Test Variable    ${NOME_CENARIO}
    Browser.New Browser    chromium    headless=${HEADLESS}
    # 1. Definindo as variáveis de caminho
    ${PATH_VIDEOS}    Normalize Path    ${DIR_BASE}/videos
    
    # 2. Criando o dicionário e atribuindo a uma variável de suíte ou de teste 
    # (Set Suite Variable ou Set Test Variable ajuda a garantir o escopo)
    ${REC_VIDEO}      Create Dictionary    dir=${PATH_VIDEOS}
    Set Test Variable    ${REC_VIDEO}
    
    # 3. Executando o contexto
    Browser.New Context    viewport={'width': 1200, 'height': 800}    tracing=${DIR_BASE}/traces/${NOME_CENARIO}.zip    recordVideo=${REC_VIDEO}
    Browser.New Page       ${SITE_SERVE_REST}


Ir para o site Serve Rest Front
    ${title}    Get Title
    Log    ${title}
    Should Contain    ${title}    ServeRest

Preencher os dados do novo usuario e cadastrar
    Click    css=.btn-link
    ${palavra_aleatoria}    Generate Random String    length=6    chars=[LETTERS]
    ${palavra_aleatoria}    Convert To Lower Case    ${palavra_aleatoria}
    ${EMAIL}    Set Variable    ${palavra_aleatoria}@emailteste.com
    Set Test Variable    ${EMAIL}
    Fill Text    css=input[data-testid='nome']    Douglas Rodrigues
    Fill Text    css=input[data-testid='email']    ${EMAIL}
    Fill Text    css=input[data-testid='password']    123456
    Check Checkbox    xpath=//*[@id="administrador"]
    Click    xpath=//*[@id='root']//button >> text="Cadastrar"

Conferir usuario cadastrado com sucesso
    Wait For Elements State    h1    visible    timeout=15s
    ${texto}    Get Text    h1
    Should Contain    ${texto}    Bem Vindo
    Get Element States    css=button[data-testid='logout']    validate    value & visible

Acessar a Lista de usuarios
    [Documentation]    Acessa o menu/listagem de usuarios apos cadastro
    Wait For Elements State    css=a[data-testid='listarUsuarios']    visible    timeout=10s
    Click    css=a[data-testid='listarUsuarios']
    Wait For Elements State    css=h1    visible    timeout=20s
    ${titulo}    Get Text    css=h1
    Should Contain    ${titulo}    Lista dos usuários
    Wait For Elements State    css=table    visible    timeout=20s

Conferir que o usuario aparece na listagem
    [Documentation]    Valida se o email cadastrado esta presente na tabela e destaca o elemento com highlight
    [Arguments]    ${email}
    ${LOCATOR_EMAIL}    Set Variable    xpath=//td[normalize-space()="${email}"]
    Wait For Elements State    ${LOCATOR_EMAIL}    visible    timeout=30s
    Scroll To Element    ${LOCATOR_EMAIL}
    ${ELEMENTO_EMAIL}    Get Element    ${LOCATOR_EMAIL}
    Highlight Elements    ${ELEMENTO_EMAIL}    duration=4s
    Take Screenshot    filename=playwright/logs/usuario_na_listagem_${email}.png    fullPage=False
    ${email_na_lista}    Get Text    ${LOCATOR_EMAIL}
    Log    ${email_na_lista}
    Should Be Equal As Strings    ${email_na_lista}    ${email}
    ${LOCATOR_NOME}    Set Variable    xpath=//tr[.//td[normalize-space()="${email}"]]/td[1]
    Wait For Elements State    ${LOCATOR_NOME}    visible    timeout=30s
    Scroll To Element    ${LOCATOR_NOME}
    ${ELEMENTO_NOME}    Get Element    ${LOCATOR_NOME}
    Highlight Elements    ${ELEMENTO_NOME}    duration=4s
    Take Screenshot    filename=playwright/logs/usuario_na_listagem_${email}_nome.png    fullPage=False
    ${nome_na_lista}    Get Text    ${LOCATOR_NOME}
    Log    ${nome_na_lista}
    Should Be Equal As Strings    ${nome_na_lista}    Douglas Rodrigues
    Sleep    2s

Finalizar Evidencias
    [Documentation]    Salva trace .zip em traces e video .webm em videos
    ${DIR_BASE}    Set Variable    ${CURDIR}/../evidences
    ${NOME_CENARIO}    Replace String    ${TEST NAME}    ${SPACE}    _
    Create Directory    ${DIR_BASE}/traces
    Create Directory    ${DIR_BASE}/videos
    ${SUFIXO}    Set Variable    PASS
    IF    '${TEST_STATUS}' != 'PASS'
        ${SUFIXO}    Set Variable    FAIL
    END
    ${TRACE_PATH}    Set Variable    ${DIR_BASE}/traces/${NOME_CENARIO}_${SUFIXO}.zip
    ${VIDEO_FINAL}    Set Variable    ${DIR_BASE}/videos/${NOME_CENARIO}_${SUFIXO}.webm
    Run Keyword And Ignore Error    Browser.Stop Tracing    ${TRACE_PATH}
    ${VID}    Run Keyword And Ignore Error    Browser.Get Page Video Path
    IF    $VID is not None
        Run Keyword And Ignore Error    Move File    ${VID}    ${VIDEO_FINAL}
    END
    Run Keyword And Ignore Error    Close Browser


Criar usuario via API
    ${RANDOM}    Generate Random String    8    [LOWER]
    ${EMAIL}    Set Variable    ${RANDOM}@test.com
    Set Test Variable    ${EMAIL}

    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session    alias=ServeRest    url=https://serverest.dev    headers=${headers}
    ${body}    Create Dictionary
    ...    nome=Douglas Rodrigues
    ...    email=${EMAIL}
    ...    password=123456
    ...    administrador=true
    ${resposta}    POST On Session
    ...    alias=ServeRest
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any

    Should Be Equal As Integers    ${resposta.status_code}    201

Logar com o usuario cadastrado via API
    ${resposta}    Http    url=https://serverest.dev/login
    ...    method=POST
    ...    body={"email": "${EMAIL}", "password": "123456"}

    Should Be Equal As Integers    ${resposta.status}    200

    LocalStorage Set Item    key=serverest/userEmail    value=${EMAIL}
    LocalStorage Set Item    key=serverest/userToken    value=${resposta["body"]["authorization"]}
    LocalStorage Set Item    key=serverest/userNome     value=Douglas Rodrigues

    Go To    url=https://front.serverest.dev/admin/home

    Take Screenshot

Cadastrar Usuario e Logar
    New Browser
    New Page    url=${SITE_SERVE_REST}
    Criar usuario via API
    Logar com o usuario cadastrado via API
    ${STORAGE_FILE}    Save Storage State
    Set Suite Variable    ${STORAGE_FILE}

Abrir o Site Serve Rest Front Logado
    New Browser    chromium    headless=${HEADLESS}
    New Context    viewport={'width': 1200, 'height': 800}
    ...            storageState=${STORAGE_FILE}
    New Page    url=https://front.serverest.dev/admin/home
    Get Text    h1    ==    Bem Vindo Douglas Rodrigues
    Take Screenshot