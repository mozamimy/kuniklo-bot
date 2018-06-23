module Lita
  module Handlers
    class Sushisyou < Handler
      URL_TEMPLATE = 'http://sushisyou.com/event/img/${YYYY}${MM}.gif'

      Target = Struct.new(:year, :month, keyword_init: true)

      route /すし将\s+(.+)$/, :sushisyou, command: true
      route /すし将\s*$/, :sushisyou_abbr, command: true
      route /sushisyou\s+(.+)$/, :sushisyou, command: true
      route /sushisyou\s*$/, :sushisyou_abbr, command: true

      def sushisyou(response)
        args = response.matches[0][0]
        target = parse_args(args)
        if target
          reply(response, target)
        else
          response.reply("Failed to parse `#{args}` :sob:, try like `2018-06`.")
        end
      end

      def sushisyou_abbr(response)
        now = Time.now
        target = Target.new(year: now.year.to_s, month: format('%02d', now.month))
        reply(response, target)
      end

      # Following list is examples of args to be parsed correctly
      #
      # - 2018-06
      # - 2018---06
      # - 2018/06
      # - 2018//06
      # - 2018 06
      # - 2018   06
      def parse_args(args)
        m = args.match(/\b(?<year>\d\d\d\d)[\/\-\s]+(?<month>\d\d)/)
        if m
          Target.new(year: m[:year], month: m[:month])
        else
          nil
        end
      end

      def reply(response, target)
        message = URL_TEMPLATE.sub('${YYYY}', target.year).sub('${MM}', target.month)
        response.reply(message)
      end

      Lita.register_handler(self)
    end
  end
end
