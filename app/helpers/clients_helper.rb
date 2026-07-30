module ClientsHelper
  # Badge colorido com a frase completa do status ("Para aprovar até 31/08").
  def status_badge(client)
    tag.span client.status_phrase, class: "badge badge--#{client.approval_status}"
  end

  # Data curta (dd/mm), em vermelho/negrito quando hoje ou já passou.
  def date_cell(date, overdue:)
    return tag.span("—", class: "date-cell date-cell--empty") if date.blank?

    classes = [ "date-cell" ]
    classes << "date-cell--overdue" if overdue

    tag.span short_date(date), class: classes.join(" "),
      title: (overdue ? "Vencido ou vencendo hoje" : nil)
  end

  def short_date(date)
    date&.strftime("%d/%m")
  end

  def br_date(date)
    date&.strftime("%d/%m/%Y")
  end

  # "Amana, Clozi e Daniel" — para o texto do resumo.
  def names_sentence(clients)
    clients.map(&:name).to_sentence(two_words_connector: " e ", last_word_connector: " e ")
  end
end
