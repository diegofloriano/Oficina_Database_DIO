# Oficina_Database_DIO
# Projeto Lógico de Banco de Dados - Oficina Mecânica

Este projeto consiste na modelagem e implementação de um sistema para controle de ordens de serviço em uma oficina mecânica.

## 🛠️ Tecnologias Utilizadas
- MySQL
- Modelagem ER / Relacional

## 📋 Funcionalidades Implementadas
- Gerenciamento de Clientes e Veículos.
- Alocação de Equipes de Mecânicos.
- Controle de Ordens de Serviço (OS) com distinção entre peças e mão de obra.
- Status de acompanhamento do serviço.

## 🗂️ Esquema Lógico
O projeto conta com tabelas de Clientes, Veículos, Equipes, Mecânicos, Ordens de Serviço, Peças e Serviços, além de tabelas associativas para permitir múltiplos itens por OS.

## 📊 Queries de Exemplo
As consultas presentes no script cobrem:
- Agrupamentos e filtros com `HAVING`.
- Criação de campos calculados (atributos derivados).
- Ordenações e junções complexas de múltiplas tabelas.

## 🚀 Como Executar
Basta rodar o arquivo `oficina_script.sql` em seu ambiente MySQL para criar a estrutura e os dados de teste.
