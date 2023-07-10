import urllib.request
import gevent
from gevent import monkey

monkey.patch_all()


def downloader(img_name, img_url):
    req = urllib.request.urlopen(img_url)

    img_content = req.read()

    with open(img_name, "wb") as f:
        f.write(img_content)


def main():
    gevent.joinall([gevent.spawn(downloader, "1.jpg", "https://inews.gtimg.com/newsapp_ls/0/11970709342_294195/0"),
                    gevent.spawn(downloader, "2.jpg", "https://inews.gtimg.com/newsapp_ls/0/11969859125_640330/0")
                    ])


if __name__ == '__main__':
    main()
