import socket

HOST = ''
PORT = 9999

print 'Starting'

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)

print 'Started'

conn, addr = s.accept()

while 1:
	data = conn.recv(1024)
	strData = data.decode('utf-8')
	print "Got Data"
	print len(strData)
	print strData

conn.close()