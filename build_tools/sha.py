import base64
import sys
import os
import io
import hashlib

_default_algorithm = hashlib.sha256

if sys.version_info[0] < 3:
    text_type = unicode  # noqa: F821
    StringIO = io.BytesIO
    def native(s, encoding='utf-8'):
        if isinstance(s, unicode):
            return s.encode(encoding)
        return s
else:
    text_type = str
    StringIO = io.StringIO
    def native(s, encoding='utf-8'):
        if isinstance(s, bytes):
            return s.decode(encoding)
        return s


def urlsafe_b64encode(data):
    """urlsafe_b64encode without padding"""
    return base64.urlsafe_b64encode(data).rstrip(b'=')


def get_hash(filename):
    with open(filename, 'rb') as f:
        st = os.fstat(f.fileno())
        bytes = f.read()
    hash_ = _default_algorithm(bytes)
    result = [filename, hash_.name, native(urlsafe_b64encode(hash_.digest()))]
    return ','.join(result)


def cli(argv):
    is_error = False
    if len(argv) == 1:
        is_error = True
    else:
        filename = argv[1]
    if is_error:
        print "Usage: python " + sys.argv[0]  + " <file> "
    else:
        result = get_hash(filename)
        print result


if __name__ == '__main__':
    cli(sys.argv)
