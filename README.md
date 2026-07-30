# Status Clozi

Painel interno da Clozi para consulta rápida do status de aprovação e programação
de posts de cada cliente.

Uma única tela lista todos os clientes em ordem alfabética, com um resumo em
texto calculado em tempo real: quantos clientes estão esperando aprovação, até
quando há posts aprovados e até quando há posts programados.

- **Stack:** Ruby on Rails 8.1, PostgreSQL, ERB + CSS puro (sem framework de JS)
- **Autenticação:** nenhuma (uso interno)
- **Idioma/timezone:** pt-BR, `America/Sao_Paulo`

## Rodando localmente

Pré-requisitos: Ruby (versão em `.ruby-version`) e um PostgreSQL rodando na máquina.

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Abra http://localhost:3000.

Se o seu PostgreSQL exigir usuário/senha/host, descomente as linhas
correspondentes em `config/database.yml` (bloco `development`) ou exporte
`DATABASE_URL` antes dos comandos:

```bash
export DATABASE_URL="postgres://usuario:senha@localhost:5432/status_clozi_development"
```

O `db/seeds.rb` é **idempotente**: ele casa os registros pelo nome do cliente e
atualiza os campos, então pode ser rodado quantas vezes quiser sem duplicar nada.
O campo `notes` não é sobrescrito pelo seed — observações escritas na tela não são
perdidas em um novo `db:seed`.

## Estrutura

```
app/
  controllers/clients_controller.rb   # index + CRUD (sem show)
  helpers/clients_helper.rb           # badges, datas dd/mm, destaque de atraso
  models/client.rb                    # validações, ordem alfabética, flags de atraso
  models/dashboard_summary.rb         # resumo do topo, calculado da coleção
  views/clients/
    index.html.erb                    # resumo em texto + tabela
    _form.html.erb                    # formulário compartilhado (new/edit)
    edit.html.erb
    new.html.erb
  views/layouts/application.html.erb  # header/footer + Google Fonts
  assets/stylesheets/application.css  # paleta e componentes
config/
  database.yml                        # DATABASE_URL em produção
  locales/pt-BR.yml
  routes.rb
db/
  migrate/                            # criação da tabela clients
  seeds.rb                            # carteira de clientes
Dockerfile                            # imagem de produção (usada pelo Render)
render.yaml                           # blueprint: web service + PostgreSQL
```

## Modelo `Client`

| Campo             | Tipo   | Observação                                                           |
| ----------------- | ------ | -------------------------------------------------------------------- |
| `name`            | string | Obrigatório                                                          |
| `approval_status` | string | `sem_posts`, `aprovado`, `pendente` ou `data_a_definir`              |
| `approval_detail` | string | Complemento do rótulo ("até 31/08"), formando "Para aprovar até 31/08" |
| `released_until`  | date   | Liberado até                                                         |
| `scheduled_until` | date   | Programado até                                                       |
| `notes`           | text   | Observações (não aparecem na tabela; visíveis na tela de edição)     |

Datas iguais a hoje ou anteriores são destacadas em vermelho/negrito na tabela e
geram uma linha de alerta no resumo.

## Editando os status

O CRUD fica em `/clients`:

- `/clients` — painel (tela principal, também na raiz `/`)
- `/clients/new` — cadastrar cliente
- `/clients/:id/edit` — atualizar status e datas (tem também o botão de remover)

## Deploy no Render

O repositório traz `render.yaml`, que cria **dois** recursos: o Web Service e um
PostgreSQL gerenciado, com o `DATABASE_URL` do banco injetado automaticamente no
serviço web.

O serviço usa o runtime **Docker**, partindo do `Dockerfile` que o Rails gera.
Isso é proposital: o projeto roda em Ruby 4.0.5, uma versão recente que o runtime
nativo de Ruby do Render pode ainda não oferecer — a imagem oficial
`ruby:4.0.5-slim` elimina esse risco.

As migrations rodam sozinhas: o `bin/docker-entrypoint` executa `db:prepare`
antes de subir o Puma. No **primeiro** deploy o `db:prepare` cria o schema e roda
o `db/seeds.rb` junto; nos deploys seguintes ele só aplica migrations pendentes,
sem tocar nos dados — ou seja, o que você editar pelo painel não é sobrescrito.

### 1. Subir o código no GitHub

```bash
git add -A
git commit -m "Painel de status de posts da Clozi"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/Status_clozi.git
git push -u origin main
```

> O `render.yaml` está configurado para a branch `main`. Se usar outro nome de
> branch, ajuste o campo `branch:` do arquivo.

### 2. Criar o Blueprint no Render

1. Entre no [dashboard do Render](https://dashboard.render.com) e clique em
   **New → Blueprint**.
2. Escolha **Connect a repository** e autorize o GitHub, se for a primeira vez.
3. Selecione o repositório. O Render detecta o `render.yaml` e mostra os dois
   recursos que serão criados (`status-clozi` e `status-clozi-db`).
4. Clique em **Apply**. O Render provisiona o banco, gera o `SECRET_KEY_BASE`,
   builda a imagem Docker e sobe o serviço.

O health check aponta para `/up`. Quando o serviço ficar verde, a URL é algo como
`https://status-clozi.onrender.com`, já com os 14 clientes carregados pelo seed.

O `config/master.key` **não** vai para o repositório (está no `.gitignore`). Não
é necessário: os assets são precompilados no build com `SECRET_KEY_BASE_DUMMY` e,
em runtime, o `SECRET_KEY_BASE` gerado pelo Render tem precedência sobre as
credentials criptografadas.

### Rodando o seed de novo (opcional)

O seed só roda sozinho na criação do banco. Se um dia quiser reaplicar a lista do
arquivo por cima do que está no ar (sobrescrevendo status e datas editados na
tela), use a aba **Shell** do serviço no Render — ela exige plano pago:

```bash
./bin/rails db:seed
```

### Plano free do Render

No plano `free` o serviço web hiberna depois de um período sem acesso — o
primeiro acesso após a hibernação leva alguns segundos. O banco PostgreSQL free
também tem prazo de expiração; para uso contínuo, troque `plan: free` por um
plano pago no `render.yaml`.

## Sobre autenticação

Não há login. Como a URL do Render é pública, se depois quiser proteger o painel,
o caminho mais curto é um HTTP Basic com a senha em variável de ambiente no
`ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  http_basic_authenticate_with(
    name: ENV["PANEL_USER"],
    password: ENV["PANEL_PASSWORD"],
    if: -> { ENV["PANEL_PASSWORD"].present? }
  )
end
```
