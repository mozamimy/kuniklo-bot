require 'artii'

module Lita
  module Handlers
    class Katakana < Handler
      Lita.register_handler(self)

      CONVERT_TABLE = {
        'ｱ' => 'A',
        'ｲ' => 'B',
        'ｳ' => 'C',
        'ｴ' => 'D',
        'ｵ' => 'E',
        'ｶ' => 'F',
        'ｷ' => 'G',
        'ｸ' => 'H',
        'ｹ' => 'I',
        'ｺ' => 'J',
        'ｻ' => 'K',
        'ｼ' => 'L',
        'ｽ' => 'M',
        'ｾ' => 'N',
        'ｿ' => 'O',
        'ﾀ' => 'P',
        'ﾁ' => 'Q',
        'ﾂ' => 'R',
        'ﾃ' => 'S',
        'ﾄ' => 'T',
        'ﾅ' => 'U',
        'ﾆ' => 'V',
        'ﾇ' => 'W',
        'ﾈ' => 'X',
        'ﾉ' => 'Y',
        'ﾊ' => 'Z',
        'ﾋ' => 'a',
        'ﾌ' => 'b',
        'ﾍ' => 'c',
        'ﾎ' => 'd',
        'ﾏ' => 'e',
        'ﾐ' => 'f',
        'ﾑ' => 'g',
        'ﾒ' => 'h',
        'ﾓ' => 'i',
        'ﾔ' => 'j',
        'ﾕ' => 'k',
        'ヱ' => 'l',
        'ﾖ' => 'm',
        'ﾗ' => 'n',
        'ﾘ' => 'o',
        'ﾙ' => 'p',
        'ﾚ' => 'q',
        'ﾛ' => 'r',
        'ﾜ' => 's',
        'ヰ' => 't',
        'ｦ' => 'u',
        'ﾝ' => 'v',
        ' ' => ' ',
      }

      route /カタカナ\s+(.+)$/, :katakana, command: true

      def katakana(response)
        converted = response.matches[0][0].chars.map { |c|  CONVERT_TABLE.fetch(c, '*') + '  ' }.join
        message = "```\n" + artii.asciify(converted) + '```'
        response.reply(message)
      end

      def artii
        @artii || Artii::Base.new(font: 'katakana')
      end
    end
  end
end
