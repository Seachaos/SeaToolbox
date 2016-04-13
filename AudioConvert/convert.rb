#!/usr/bin/ruby

def convertAll
	list =  Dir["./input/*"]
	list.each do |file|
		if file =~ /(m4a|flac|aif)$/ then
			output = file.gsub(/(\.[a-zA-Z0-9]+)$/, '.wav')
			output = output.gsub(/^\.\/ori/, './output')
	# 		puts output
			cli = 'ffmpeg -i "' + file + '" -b 16 -ar 44100 ' + ' -acodec pcm_s16le "' + output + '" '
			puts 'Do CLI: >>>>>'
			puts cli
			system cli
		end
	end
end


convertAll