import socket


IP = '192.168.15.2'
PORT = 8000

BUFFER_SIZE = 2000   # Normally 1024, but we want fast response


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((IP, PORT))
s.listen(1)

conn, addr = s.accept()
print('IP connected:', addr)

while 1:
    data = conn.recv(BUFFER_SIZE)
    if not data:
        break
    print("Data received:", data.decode('utf-8'))
    conn.send(data)
conn.close()
