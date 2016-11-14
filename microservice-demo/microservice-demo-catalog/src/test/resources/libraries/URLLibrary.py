import urllib

class URLLibrary(object):
    def url_encode(self, url):
        return urllib.quote(url)

    def url_decode(self, url):
        return urllib.unquote(url)
