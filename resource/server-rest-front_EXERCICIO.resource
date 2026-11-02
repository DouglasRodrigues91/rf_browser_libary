*** Settings ***
Library    Browser
Library    String

*** Variables ***
${BROWSER}            chromium
${HEADLESS}           ${False}
${SITE_SERVE_REST}    https://front.serverest.dev/login


*** Keywords ***
Abrir o navegador
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Context    viewport={'width': 1200, 'height': 800}

Ir para o site Serve Rest Front
    New Page    ${SITE_SERVE_REST}
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
    Take Screenshot    filename=playwright/logs/usuario_na_listagem_EXERCICIO_${email}.png    fullPage=False
    ${email_na_lista}    Get Text    ${LOCATOR_EMAIL}
    Log    ${email_na_lista}
    Should Be Equal As Strings    ${email_na_lista}    ${email}
    ${LOCATOR_NOME}    Set Variable    xpath=//tr[.//td[normalize-space()="${email}"]]/td[1]
    Wait For Elements State    ${LOCATOR_NOME}    visible    timeout=30s
    Scroll To Element    ${LOCATOR_NOME}
    ${ELEMENTO_NOME}    Get Element    ${LOCATOR_NOME}
    Highlight Elements    ${ELEMENTO_NOME}    duration=4s
    Take Screenshot    filename=playwright/logs/usuario_na_listagem_EXERCICIO_${email}_nome.png    fullPage=False
    ${nome_na_lista}    Get Text    ${LOCATOR_NOME}
    Log    ${nome_na_lista}
    Should Be Equal As Strings    ${nome_na_lista}    Douglas Rodrigues
    Sleep    2s

Cadastrar novo usuario para logar
    [Documentation]    Cadastra um novo usuario dinamico para realizar o login
    Click    css=.btn-link
    ${palavra_aleatoria}    Generate Random String    length=6    chars=[LETTERS]
    ${palavra_aleatoria}    Convert To Lower Case    ${palavra_aleatoria}
    ${EMAIL_LOGIN}    Set Variable    ${palavra_aleatoria}@emailteste.com
    Set Test Variable    ${EMAIL_LOGIN}
    Fill Text    css=input[data-testid='nome']    Usuario Login
    Fill Text    css=input[data-testid='email']    ${EMAIL_LOGIN}
    Fill Text    css=input[data-testid='password']    123456
    Check Checkbox    xpath=//*[@id="administrador"]
    Click    xpath=//*[@id='root']//button >> text="Cadastrar"
    Wait For Elements State    h1    visible    timeout=15s
    ${texto_cadastro}    Get Text    h1
    Should Contain    ${texto_cadastro}    Bem Vindo
    Get Element States    css=button[data-testid='logout']    validate    value & visible

Fazer login com usuario cadastrado
    [Documentation]    Realiza login com o usuario cadastrado
    ${count_logout}    Get Element Count    css=button[data-testid='logout']
    IF    ${count_logout} > 0
        Click    css=button[data-testid='logout']
        Sleep    2s
    END
    New Page    https://front.serverest.dev/login
    Sleep    2s
    Wait For Elements State    css=input[data-testid='email']    visible    timeout=30s
    Fill Text    css=input[data-testid='email']    ${EMAIL_LOGIN}
    Wait For Elements State    css=input[data-testid='senha']    visible    timeout=30s
    Fill Text    css=input[data-testid='senha']    123456
    Wait For Elements State    css=button[data-testid='entrar']    enabled    timeout=10s
    Click    css=button[data-testid='entrar']
    Sleep    3s
    ${title}    Get Title
    Log    ${title}
    ${texto_home}    Get Text    h1
    Log    ${texto_home}
    Should Contain    ${texto_home}    Bem Vindo

Cadastrar um novo produto
    [Documentation]    Cadastra um novo produto com dados dinamicos
    Go To    https://front.serverest.dev/admin/cadastrarprodutos
    Wait For Elements State    css=input[data-testid='nome']    visible    timeout=15s
    ${palavra_produto}    Generate Random String    length=5    chars=[LETTERS]
    ${palavra_produto}    Convert To Lower Case    ${palavra_produto}
    ${NOME_PRODUTO}    Set Variable    ProdutoTeste${palavra_produto}
    Set Test Variable    ${NOME_PRODUTO}
    Fill Text    css=input[data-testid='nome']    ${NOME_PRODUTO}
    Fill Text    css=input[data-testid='preco']    150
    Fill Text    css=textarea[data-testid='descricao']    Produto cadastrado via automacao
    Fill Text    css=input[data-testid='quantity']    50
    Click    css=button[data-testid='cadastarProdutos']
    Sleep    3s

Conferir que o produto aparece na listagem
    [Documentation]    Acessa a listagem de produtos, destaca apenas o produto desejado e valida
    Go To    https://front.serverest.dev/admin/listarprodutos
    Wait For Elements State    css=table    visible    timeout=25s
    ${LOCATOR_PRODUTO}    Set Variable    xpath=//td[normalize-space()="${NOME_PRODUTO}"]
    Wait For Elements State    ${LOCATOR_PRODUTO}    visible    timeout=30s
    Scroll To Element    ${LOCATOR_PRODUTO}
    ${ELEMENTO_PRODUTO}    Get Element    ${LOCATOR_PRODUTO}
    Highlight Elements    ${ELEMENTO_PRODUTO}    duration=4s
    Take Screenshot    filename=playwright/logs/produto_na_listagem_${NOME_PRODUTO}.png    fullPage=False
    ${produto_na_lista}    Get Text    ${LOCATOR_PRODUTO}
    Log    ${produto_na_lista}
    Should Be Equal As Strings    ${produto_na_lista}    ${NOME_PRODUTO}
    Sleep    2s