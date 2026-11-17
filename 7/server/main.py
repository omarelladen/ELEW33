import socket
import threading
from typing import Annotated
from urllib.parse import quote

import uvicorn
from fastapi import FastAPI, Form, HTTPException
from fastapi.responses import HTMLResponse, Response, RedirectResponse


__version__ = "0.1.0"

IP = "0.0.0.0"
PORT = 8003
BUFFER_SIZE = 2000
TIMEOUT = 5.0

conn = None

app = FastAPI(
    title="server",
    version=__version__
)


def start_socket_server():
    global conn

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((IP, PORT))
    s.listen(1)

    print(f"Waiting Nios on {IP}:{PORT}...")

    while True:
        c, addr = s.accept()
        print("IP connected:", addr)
        conn = c

def send_and_recv_socket(msg: str) -> str:
    global conn

    if conn is None:
        raise HTTPException(status_code=503, detail="Nios not connected yet")

    try:
        conn.settimeout(TIMEOUT)
        conn.send(msg.encode("utf-8"))

        data = conn.recv(BUFFER_SIZE)
        if not data:
            conn = None
            raise HTTPException(status_code=502, detail="Nios disconnected")
        return data.decode("utf-8", errors="replace")

    except socket.timeout:
        raise HTTPException(status_code=504, detail="Timeout: Nios didn't respond")
    except Exception as e:
        conn = None
        raise HTTPException(status_code=500, detail=f"Socket error: {e}")


@app.head("/", include_in_schema=False)
async def head_root():
    pass

@app.get("/favicon.ico", include_in_schema=False)
async def get_favicon():
    return Response(status_code=204)  # FileResponse("favicon.ico")

@app.get("/", response_class=HTMLResponse)
async def get_root():
    return await get_index()

@app.get("/index.html", response_class=HTMLResponse)
async def get_index():
    with open("index.html", "r", encoding="utf-8") as f:
        content = f.read()
    return HTMLResponse(content=content)

@app.get("/msg", response_class=HTMLResponse)
async def get_msg(response: str = "No Response"):
    return HTMLResponse(
        content=f"""
        <html>
            <head>
                <title>Message</title>
            </head>
            <body style="text-align: center;">
                <h1>Message from Nios</h1>
                {response}
                <br><br>
                <button onclick="window.location.href='/'">Back</button>
            </body>
        </html>
        """
    )

@app.post("/send_msg")
async def post_send_msg(msg: Annotated[str, Form()]):
    if not msg.strip():
        raise HTTPException(detail="Message can't be empy", status_code=422)

    # Send to socket and wait response
    response_nios = send_and_recv_socket(msg)

    # Redirect to /msg sending the response on URL
    return RedirectResponse(
        url=f"/msg?response={quote(response_nios)}",
        status_code=303
    )

@app.on_event("startup")
def startup_event():
    threading.Thread(target=start_socket_server, daemon=True).start()


if __name__ == "__main__":
    uvicorn.run(
        app="main:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
    )
