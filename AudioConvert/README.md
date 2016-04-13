# AudioConvert

this script is convert audio by ffmpeg  
put music file in input, and modify 'convert.rb' parameter like this

		cli = 'ffmpeg -i "' + file + '" -b 16 -ar 44100 ' + ' -acodec pcm_s16le "' + output + '" '

and it will to output :)

