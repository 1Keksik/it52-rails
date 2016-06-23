module Telegram
  class Request
    COMMANDS = %i(next previous get)

    attr_reader *%i(chat_id action message)

    def initialize(params)
      @chat_id = params['message']['chat']['id']
      @message = Message.new(:message, @chat_id)
      @action = parse_command(params['message']['text'])
    end

    def reply!
      return unknown if @action.nil?
      return send(@action.first) if @action.second <= 0
      send(*@action)
    end

    def get(id = Event.last.id)
      event = Event.find(id)
      return not_found unless event.published
      text = event.construct_telegram_message
      message.send_message(text)
    rescue ActiveRecord::RecordNotFound => e
      not_found
    end

    def next(quantity = 1)
      quantity = 5 if quantity > 5
      post_events Event.future.published.limit(quantity)
    end

    def previous(quantity = 1)
      quantity = 5 if quantity > 5
      post_events Event.past.published.limit(quantity)
    end

    def post_events(events)
      return not_found if events.empty?
      events.each do |event|
        text = event.construct_telegram_message(true)
        message.send_message(text)
      end
    end

    def not_found
      message.send_message I18n.t('telegram.not_found')
    end

    def unknown
      message.send_message I18n.t('telegram.unknown_command', list: COMMANDS.map{ |c| "/#{c}" }.to_sentence)
    end

    private

    def parse_command(text)
      return nil if text.nil?
      words = text.split
      return nil if (words.first =~ /^\//).nil?
      command = words.first[1..-1].split('@').first.to_sym
      return nil unless COMMANDS.include? command
      [ command, words.second.to_i ]
    end
  end
end
