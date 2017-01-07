import socket
import struct
import sys, signal

def signal_handler(signal, frame):
	print("\nClosing")
	sys.exit(0)
	
signal.signal(signal.SIGINT, signal_handler)

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
	byteData = bytearray(data)

	if len(byteData) != 8:
		continue
	
	xBytes = byteData[:4]
	yBytes = byteData[-4:]
	
	xFloat = struct.unpack('>f', xBytes)[0]
	yFloat = struct.unpack('>f', yBytes)[0]
	
	xFloat = xFloat + 10
	yFloat = yFloat + 10
	
	print xFloat, yFloat
	
	xyPacked = struct.pack('>ff', xFloat, yFloat)
	
	conn.send(xyPacked)
	
	print "Sent"

conn.close()