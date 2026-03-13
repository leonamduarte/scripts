import json
import requests

# ===== CONFIG =====
# Orientações para criação do TOKEN
# O GitLab é mais “tudo ou nada” com permissões, então vamos direto ao ponto:
# Permissão exata que você precisa no GitLab
#
# Para criar issues via API, o GitLab exige obrigatoriamente o escopo:
# api
# Escopo completo da API.
# Sem isso, o GitLab simplesmente bloqueia qualquer tentativa de criar issue, label, board, ou mexer em projetos.
#
# Esse escopo cobre:
#
# criar issues
# criar labels
# editar issues
# ler e escrever dados do projeto via API
#
# O GitLab não tem um escopo granular tipo “só issues”, então não tem como reduzir mais.

# Orientações para encontrar o PROJECT_ID
# Settings -> General -> Project ID

GITLAB_TOKEN = "TOKEN"
GITLAB_URL = "https://gitlab.com"  # ou endereço da sua empresa
PROJECT_ID = 12345  # ID numérico do projeto no GitLab

CRIAR_LABELS = True
# ==================

headers = {"PRIVATE-TOKEN": GITLAB_TOKEN}


def criar_label(nome):
    url = f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/labels"
    payload = {"name": nome}

    r = requests.post(url, headers=headers, data=payload)
    if r.status_code not in [200, 201]:
        pass  # ignora erros se a label já existir


def criar_issue(titulo, corpo, labels=None):
    url = f"{GITLAB_URL}/api/v4/projects/{PROJECT_ID}/issues"
    payload = {
        "title": titulo,
        "description": corpo,
    }
    if labels:
        payload["labels"] = ",".join(labels)

    r = requests.post(url, headers=headers, data=payload)
    if r.status_code not in [200, 201]:
        print(f"Erro ao criar issue: {r.status_code} - {r.text}")
    else:
        print(f"Issue criada: {titulo}")


def main():
    with open("trello_board.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    listas = {l["id"]: l["name"] for l in data["lists"]}
    labels_criadas = set()

    if CRIAR_LABELS:
        for nome_lista in listas.values():
            if nome_lista not in labels_criadas:
                criar_label(nome_lista)
                labels_criadas.add(nome_lista)

    for card in data["cards"]:
        if card["closed"]:
            continue

        titulo = card["name"]
        descricao = card.get("desc", "")

        # checklists → markdown
        check_md = ""
        for checklist in data.get("checklists", []):
            if checklist["idCard"] == card["id"]:
                check_md += f"\n\n### {checklist['name']}\n"
                for item in checklist["checkItems"]:
                    mark = "[x]" if item["state"] == "complete" else "[ ]"
                    check_md += f"- {mark} {item['name']}\n"

        corpo = f"{descricao}\n{check_md}"

        label = listas.get(card["idList"])
        labels = [label] if label else []

        criar_issue(titulo, corpo, labels)

    print("Migração concluída!")


if __name__ == "__main__":
    main()
