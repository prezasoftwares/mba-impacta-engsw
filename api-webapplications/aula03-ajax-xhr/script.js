window.onload = function () {
    let botao = document.querySelector("#botao-calculo");
    botao.addEventListener('click', calculoImcAPIfetch);
    imcTableGETfetch();
}


function calculoImcAPIfetch() {
    let form = document.querySelector("#dados-usuario");
    let peso = form.peso.value;
    let altura = form.altura.value;

    fetch('http://localhost:8080/imc/calculate', {
        method: 'POST',
        body: JSON.stringify({
            'height': altura,
            'weight': peso
        }),
        mode: 'cors',
        redirect: 'follow',
        headers: new Headers({
            'Content-Type': 'application/json'
        })
    })
        .then(function (response) {
            response.json().then(data => {
                console.log("Resultado da Requisição POST");
                console.log(data);

                console.log("Peso    : " + data.weight + " kg");
                console.log("Altura  : " + data.height + " m");
                console.log("IMC     : " + data.imc);
                console.log("Classif.: " + data.imcDescription);

                escreveResultado(parseFloat(data.imc).toFixed(1), data.imcDescription);
            });
        });
}


function escreveResultado(imc, classificacao) {
    let containerResultado = document.querySelector(".resultado");

    if (containerResultado === null) {
        containerResultado = document.createElement("div");
        containerResultado.classList.add("resultado");

        let resultadoIMC = document.createElement("p");
        resultadoIMC.setAttribute("id", "resultado-imc-numero");
        resultadoIMC.textContent = "O IMC é " + imc;
        containerResultado.appendChild(resultadoIMC);

        let resultadoClassificacao = document.createElement("p");
        resultadoClassificacao.setAttribute("id", "resultado-imc-classificacao");
        resultadoClassificacao.textContent = "Classificação: " + classificacao;
        containerResultado.appendChild(resultadoClassificacao);

        document.body.appendChild(containerResultado);
    }
    else {
        let resultadoIMC = document.querySelector("#resultado-imc-numero");
        resultadoIMC.textContent = "O IMC é " + imc;

        let resultadoClassificacao = document.querySelector("#resultado-imc-classificacao");
        resultadoClassificacao.textContent = "Classificação: " + classificacao;
    }
}


function classificaIMC(imc) {
    if (imc < 18.5) {
        return "Magreza";
    }
    else if (imc >= 18.5 && imc < 25) {
        return "Normal";
    }
    else if (imc >= 25 && imc < 30) {
        return "Sobrepeso";
    }
    else if (imc >= 30) {
        return "Obesidade";
    }
}


function imcTableGETfetch() {
    fetch('http://localhost:8080/imc/table', {
        method: 'GET',
        mode: 'cors',
        redirect: 'follow',
        headers: new Headers({
            'Content-Type': 'application/json'
        })
    })
        .then(function (response) {
            response.json().then(data => {
                console.log("Resultado da Requisição GET");
                console.log(data);

                escreveTabela(data);
            });
        });
}


function escreveTabela(dataObject) {
    // Novo Div
    let tabelaImcDiv = document.createElement("div");
    document.body.appendChild(tabelaImcDiv);

    // Nova Tabela
    let tabelaImcTable = document.createElement("table");
    tabelaImcTable.setAttribute("id", "tabela-imc");
    tabelaImcDiv.appendChild(tabelaImcTable);

    // Header da Tabela
    let tabelaImcHeaderTr = document.createElement("tr");
    tabelaImcTable.appendChild(tabelaImcHeaderTr);
    let tabelaImcHeaderThValor = document.createElement("th");
    tabelaImcHeaderThValor.textContent = "Valor";
    tabelaImcHeaderTr.appendChild(tabelaImcHeaderThValor);
    let tabelaImcHeaderThDescricao = document.createElement("th");
    tabelaImcHeaderThDescricao.textContent = "Descrição";
    tabelaImcHeaderTr.appendChild(tabelaImcHeaderThDescricao);

    Object.entries(dataObject).forEach(([tabelaValor, tabelaDescricao]) => {
        console.log(tabelaValor + ' - ' + tabelaDescricao);
        
        let tabelaImcTr = document.createElement("tr");
        tabelaImcTr.classList.add("tabela-imc-tr");
        tabelaImcTable.appendChild(tabelaImcTr);

        let tabelaImcTdValor = document.createElement("td");
        tabelaImcTdValor.textContent = tabelaValor;
        tabelaImcTr.appendChild(tabelaImcTdValor);

        let tabelaImcTdDescricao = document.createElement("td");
        tabelaImcTdDescricao.textContent = tabelaDescricao;
        tabelaImcTr.appendChild(tabelaImcTdDescricao);
    })
}
