function page = curlUrl(url)

curlPath = 'C:\matlab\webMap\curl-7.33.0-ssl-sspi-zlib-static-bin-w32\curl-7.33.0-ssl-sspi-zlib-static-bin-w32\curl.exe';

[status,page] =  system([curlPath ' -k -L ' url]);