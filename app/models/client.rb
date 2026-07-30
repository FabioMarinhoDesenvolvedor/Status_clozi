class Client < ApplicationRecord
  APPROVAL_STATUSES = %w[sem_posts aprovado pendente data_a_definir].freeze

  STATUS_LABELS = {
    "sem_posts" => "Sem posts para aprovação",
    "aprovado" => "Todo conteúdo aprovado",
    "pendente" => "Para aprovar",
    "data_a_definir" => "Conteúdo com data a definir"
  }.freeze

  validates :name, presence: true
  validates :approval_status, presence: true, inclusion: { in: APPROVAL_STATUSES }

  scope :pending_approval, -> { where(approval_status: "pendente") }

  # Ordem alfabética ignorando acentos: "Lá de Casa" vem antes de "Linkedin".
  # Ordenar no Ruby evita depender do collation do PostgreSQL.
  def self.alphabetical
    all.to_a.sort_by { |client| ActiveSupport::Inflector.transliterate(client.name).downcase }
  end

  def status_label
    STATUS_LABELS.fetch(approval_status, approval_status)
  end

  # Rótulo + detalhe numa frase só: "Para aprovar até 31/08".
  def status_phrase
    [ status_label, approval_detail.presence ].compact.join(" ")
  end

  def released_overdue?
    released_until.present? && released_until <= Date.current
  end

  def scheduled_overdue?
    scheduled_until.present? && scheduled_until <= Date.current
  end

  def overdue?
    released_overdue? || scheduled_overdue?
  end
end
