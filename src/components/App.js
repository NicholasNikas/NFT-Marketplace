import React, { useEffect, useState } from 'react'
import Web3 from 'web3'
import detectEthereumProvider from '@metamask/detect-provider'
import KryptoBird from '../abis/KryptoBird.json'

const App = () => {
  const [account, setAccount] = useState([])
  const [contract, setContract] = useState(null)
  const [kryptoBirdz, setKryptoBirdz] = useState([])
  const [kryptoBird, setKryptoBird] = useState(null)

  // first up is to check ethereum provider
  const loadWeb3 = async () => {
    const provider = await detectEthereumProvider()

    // modern browsers
    // if there is a provider then lets log its working
    // and access the window from the doc to set the Web3 to the provider
    if (provider) {
      console.log('ethereum wallet is connected!')
      window.web3 = new Web3(provider)
    } else {
      console.log('No ethereum wallet detected')
    }
  }

  const loadBlockchainData = async () => {
    const web3 = window.web3
    const requestedAccounts = await web3.eth.requestAccounts()
    setAccount(requestedAccounts)

    const networkId = await web3.eth.net.getId()
    const networkData = KryptoBird.networks[networkId]

    if (networkData) {
      const abi = KryptoBird.abi
      const address = networkData.address
      const contract = await new web3.eth.Contract(abi, address)
      setContract(contract)

      // call the total supply of our KryptoBirdz
      const totalSupply = await contract.methods.totalSupply().call()

      // set up an array to keep track of tokens
      // load KryptoBirdz
      for (let i = 1; i <= totalSupply; i++) {
        const KryptoBird = await contract.methods.kryptoBirdz(i - 1).call()
        setKryptoBirdz((bird) => [...bird, KryptoBird])
      }
    } else {
      window.alert('Smart contract not deployed')
    }
  }

  const mint = async (bird) => {
    contract.methods
      .mint(bird)
      .send({ from: account[0] })
      .once('receipt', (receipt) => {
        setKryptoBirdz([...kryptoBirdz, bird])
      })
  }

  useEffect(async () => {
    await loadWeb3()
    await loadBlockchainData()
  }, [])

  return (
    <div>
      {console.log('kryptoBirdz', kryptoBirdz)}
      <nav className='navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow'>
        <div
          className='navbar-brand col-sm-3 col-md-3 mr-0'
          style={{ color: 'white' }}
        >
          Krypto Birdz NFTs (Non Fungible Tokens)
        </div>
        <ul className='navbar-nav px-3'>
          <li className='nav-item text-nowrap d-none d-sm-none d-sm-block'>
            <small className='text-white'>{account}</small>
          </li>
        </ul>
      </nav>

      <div className='container-fluid mt-1'>
        <div className='row'>
          <main role='main' className='col-lg-12 d-flex text-center'>
            <div className='content mr-auto ml-auto' style={{ opacity: 0.8 }}>
              <h1 style={{ color: 'black' }}>KryptoBirdz - NFT Marketplace</h1>
              <form
                onSubmit={(event) => {
                  event.preventDefault()
                  mint(kryptoBird.value)
                }}
              >
                <input
                  type='text'
                  placeholder='Add a file location'
                  className='form-control mb-1'
                  ref={(input) => {
                    setKryptoBird(input)
                  }}
                />
                <input
                  style={{ margin: '6px' }}
                  type='submit'
                  className='btn btn-primary btn-black'
                  value='MINT'
                />
              </form>
            </div>
          </main>
        </div>
      </div>
    </div>
  )
}

export default App
