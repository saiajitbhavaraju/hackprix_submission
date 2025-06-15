from flask import Flask, jsonify, request
from web3 import Web3

# --- Configuration (MODIFIED FOR GANACHE) ---

# MODIFIED: Point to your local Ganache RPC server
GANACHE_RPC_URL = "http://127.0.0.1:7545" 

# MODIFIED: Use an account from Ganache. Let's use the first one.
# Copy the address from the Ganache UI
WALLET_ADDRESS = "0xD786E207EcE35F1C19ccC3BFD99089A77b47d0F0" 
# Click the key icon next to the address in Ganache to get the private key
PRIVATE_KEY = "0x247ba1c7d35fb2580edf5d24c361b43ae24e9f39f1c55977e669fdad079d43b7" 

# --- Flask & Web3 Setup ---
app = Flask(__name__)
# MODIFIED: Connect to Ganache
w3 = Web3(Web3.HTTPProvider(GANACHE_RPC_URL)) 

if not w3.is_connected():
    raise ConnectionError("Failed to connect to Ganache. Is it running?")
else:
    print("Successfully connected to local Ganache blockchain.")

# ... (The rest of the file remains exactly the same) ...
# @app.route('/get_balance', ...)
# @app.route('/make_payment', ...)
# if __name__ == '__main__': ...

# --- API Endpoints ---
@app.route('/get_balance', methods=['GET'])
def get_balance():
    try:
        balance_wei = w3.eth.get_balance(WALLET_ADDRESS)
        balance_eth = w3.from_wei(balance_wei, 'ether')
        return jsonify({
            'address': WALLET_ADDRESS,
            'balance_eth': str(balance_eth)
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/make_payment', methods=['POST'])
def make_payment():
    data = request.get_json()
    if not data or 'to_address' not in data or 'amount_eth' not in data:
        return jsonify({'error': 'Missing request data'}), 400

    try:
        recipient_address = data['to_address']
        amount_to_send_eth = data['amount_eth']
        
        if not w3.is_address(recipient_address):
            return jsonify({'error': 'Invalid recipient address'}), 400

        tx = {
            'chainId': w3.eth.chain_id,
            'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS),
            'to': recipient_address,
            'value': w3.to_wei(amount_to_send_eth, 'ether'),
            'gas': 21000,
            'gasPrice': w3.eth.gas_price,
        }

        # Sign the transaction
        signed_tx = w3.eth.account.sign_transaction(tx, PRIVATE_KEY)
        
        # =================================================================
        # --- THIS IS THE FINAL, CORRECTED LINE ---
        tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
        # --- The attribute is raw_transaction (with an underscore) ---
        # =================================================================

        return jsonify({
            'message': 'Transaction initiated successfully!',
            'transaction_hash': w3.to_hex(tx_hash)
        }), 200

    except Exception as e:
        print(f"Error details: {e}")
        return jsonify({'error': 'An error occurred while sending the transaction.'}), 500

# --- Run the App ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

