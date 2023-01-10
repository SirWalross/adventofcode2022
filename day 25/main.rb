def convert_to_decimal(snafu)
    number = 0
    snafu.chars.reverse.each.with_index(-1) do |char, index| case char
        when '1' 
            number += (5 ** index)
        when '2' 
            number += 2 * (5 ** index)
        when '-' 
            number -= (5 ** index)
        when '=' 
            number -= 2 * (5 ** index) 
        end
    end
    return number
end
def convert_to_snafu(number)
    conversion = ['=', '-', '0', '1', '2']
    number = Integer(number)
    snafu = ""
    limit = (Math::log((number * 2) - 1)/Math::log(5)).floor # number of digits in snafu number
    for counter in limit.downto(0)
        if number >= 2 * 5 ** counter - (counter - 1).downto(0).to_a.map {|x| 2 * (5 ** x)}.sum # check if number is ge than 2==
            snafu += "2"
        elsif number >= 5 ** counter - (counter - 1).downto(0).to_a.map {|x| 2 * (5 ** x)}.sum # check if number ge than 1==
            snafu += "1"
        elsif number < -5 ** counter - (counter - 1).downto(0).to_a.map {|x| 2 * (5 ** x)}.sum # check if number is lt -==
            snafu += "="
        elsif number < - (counter - 1).downto(0).to_a.map {|x| 2 * (5 ** x)}.sum # check if number is lt 0==
            snafu += "-"
        else
            snafu += "0"
        end
        number -= convert_to_decimal(snafu[-1]) * (5.0 ** (counter + 1))
    end
    return snafu
end
lines = File.readlines('input')
puts convert_to_snafu(lines.map {|line| convert_to_decimal(line) }.sum)
