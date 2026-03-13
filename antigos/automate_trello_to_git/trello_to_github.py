import json
import requests

# ====== CONFIGURAÇÕES ======
# Orientações para criação do TOKEN
# A permissão exata é:
# repo → repo:public_repo (se o repositório for público)
# ou
# repo completo (se o repositório for privado)
#
# Dentro da interface do GitHub, isso aparece como:
#
# Repo → Contents
#
# Repo → Issues
#
# Repo → Metadata
#
# Esses três já cobrem tudo o que o script faz:
# criar issues, criar labels e ler dados do repositório.
#
# Não precisa liberar nada de Actions, Admin, Security ou outras áreas mais sensíveis. Isso mantém o token enxuto e evita que vire uma granada se vazar.
#
# Um detalhe útil para o futuro: se quiser deixar ainda mais seguro, você pode restringir o token para apenas um repositório específico na própria criação do token. GitHub agora permite isso. É ótimo para migrações únicas como essa.

GITHUB_TOKEN = "SEU_TOKEN_AQUI"
OWNER = "bashln"  # exemplo: bashln
REPO = "tasks"  # exemplo: leonamsh

CRIAR_LABELS = True  # Se quiser transformar as listas do Trello em labels

# ===========================


def criar_label(nome):
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/labels"
    headers = {"Authorization": f"token {GITHUB_TOKEN}"}
    payload = {"name": nome}

    r = requests.post(url, json=payload, headers=headers)
    # Ignora erro se label já existe
    if r.status_code not in [200, 201]:
        pass


def criar_issue(titulo, corpo, labels=None):
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/issues"
    headers = {"Authorization": f"token {GITHUB_TOKEN}"}
    payload = {"title": titulo, "body": corpo, "labels": labels or []}

    r = requests.post(url, json=payload, headers=headers)
    if r.status_code not in [200, 201]:
        print(f"Erro ao criar issue: {r.status_code} - {r.text}")
    else:
        print(f"Issue criada: {titulo}")


def main():
    with open("trello_board.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    listas = {l["id"]: l["name"] for l in data["lists"]}
    labels_criadas = set()

    # Criando labels das listas, se habilitado
    if CRIAR_LABELS:
        for nome_lista in listas.values():
            if nome_lista not in labels_criadas:
                criar_label(nome_lista)
                labels_criadas.add(nome_lista)

    for card in data["cards"]:
        if card["closed"]:
            continue  # Ignora cartões arquivados

        titulo = card["name"]
        descricao = card.get("desc", "")

        # Converte checklists em markdown
        check_md = ""
        for checklist in data.get("checklists", []):
            if checklist["idCard"] == card["id"]:
                check_md += f"\n\n### {checklist['name']}\n"
                for item in checklist["checkItems"]:
                    mark = "[x]" if item["state"] == "complete" else "[ ]"
                    check_md += f"- {mark} {item['name']}\n"

        corpo = f"{descricao}\n{check_md}"

        label_da_lista = listas.get(card["idList"])
        labels = [label_da_lista] if CRIAR_LABELS else []

        criar_issue(titulo, corpo, labels)

    print("Migração concluída!")


if __name__ == "__main__":
    main()
