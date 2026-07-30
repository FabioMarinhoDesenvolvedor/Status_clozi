# Resumo calculado dinamicamente a partir dos clientes carregados.
# Sem nada hardcoded: tudo derivado da coleção que recebe.
class DashboardSummary
  attr_reader :clients

  def initialize(clients)
    @clients = clients.to_a
  end

  def total
    clients.size
  end

  def pending
    clients.select { |c| c.approval_status == "pendente" }
  end

  def pending_count
    pending.size
  end

  def overdue
    clients.select(&:overdue?)
  end

  def released_dates
    @released_dates ||= clients.filter_map(&:released_until).sort
  end

  def scheduled_dates
    @scheduled_dates ||= clients.filter_map(&:scheduled_until).sort
  end

  def released_range
    released_dates.minmax
  end

  def scheduled_range
    scheduled_dates.minmax
  end
end
