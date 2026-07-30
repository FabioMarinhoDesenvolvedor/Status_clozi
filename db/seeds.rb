# Carteira de clientes da Clozi — snapshot de 30/07/2026.
#
# Idempotente: roda quantas vezes quiser (`bin/rails db:seed`). Casa pelo `name`
# e atualiza os demais campos, então nunca duplica cliente.

CLIENTS = [
  {
    name: "Amana",
    approval_status: "sem_posts",
    approval_detail: nil,
    released_until: nil,
    scheduled_until: nil
  },
  {
    name: "Clozi",
    approval_status: "sem_posts",
    approval_detail: nil,
    released_until: Date.new(2026, 7, 31),
    scheduled_until: Date.new(2026, 7, 31)
  },
  {
    name: "Daniel",
    approval_status: "aprovado",
    approval_detail: nil,
    released_until: Date.new(2026, 8, 29),
    scheduled_until: Date.new(2026, 8, 27)
  },
  {
    name: "Paper",
    approval_status: "aprovado",
    approval_detail: nil,
    released_until: Date.new(2026, 8, 31),
    scheduled_until: Date.new(2026, 8, 27)
  },
  {
    name: "Engegap",
    approval_status: "aprovado",
    approval_detail: nil,
    released_until: Date.new(2026, 8, 28),
    scheduled_until: Date.new(2026, 8, 26)
  },
  {
    name: "Exportsul BR",
    approval_status: "pendente",
    approval_detail: "até 31/08",
    released_until: Date.new(2026, 8, 15),
    scheduled_until: Date.new(2026, 7, 29)
  },
  {
    name: "Exportsul Europa",
    approval_status: "pendente",
    approval_detail: "11/08 e 21/08",
    released_until: Date.new(2026, 8, 26),
    scheduled_until: Date.new(2026, 7, 31)
  },
  {
    name: "Linkedin Exportsul",
    approval_status: "aprovado",
    approval_detail: nil,
    released_until: Date.new(2026, 8, 27),
    scheduled_until: Date.new(2026, 8, 19)
  },
  {
    name: "Myli",
    approval_status: "data_a_definir",
    approval_detail: nil,
    released_until: Date.new(2026, 8, 11),
    scheduled_until: Date.new(2026, 8, 11)
  },
  {
    name: "Lá de Casa",
    approval_status: "pendente",
    approval_detail: "até 31/08",
    released_until: Date.new(2026, 8, 8),
    scheduled_until: Date.new(2026, 7, 31)
  },
  {
    name: "MDC",
    approval_status: "aprovado",
    approval_detail: nil,
    released_until: Date.new(2026, 8, 31),
    scheduled_until: Date.new(2026, 8, 25)
  },
  {
    name: "Minke",
    approval_status: "aprovado",
    approval_detail: nil,
    released_until: Date.new(2026, 8, 30),
    scheduled_until: Date.new(2026, 8, 10)
  },
  {
    name: "TT Interiores",
    approval_status: "pendente",
    approval_detail: "até 19/08",
    released_until: Date.new(2026, 8, 9),
    scheduled_until: Date.new(2026, 8, 31)
  },
  {
    name: "Way",
    approval_status: "aprovado",
    approval_detail: nil,
    released_until: Date.new(2026, 9, 5),
    scheduled_until: Date.new(2026, 8, 16)
  }
].freeze

CLIENTS.each do |attrs|
  client = Client.find_or_initialize_by(name: attrs[:name])
  client.update!(attrs)
end

puts "Seed concluído: #{Client.count} clientes."
