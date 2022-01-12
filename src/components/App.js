import React, { useEffect, useState } from 'react'
import Web3 from 'web3'
import detectEthereumProvider from '@metamask/detect-provider'
import KryptoBird from '../abis/KryptoBird.json'

const App = () => {
  const [account, setAccount] = useState([])

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
      console.log(contract)
    }
  }

  useEffect(async () => {
    await loadWeb3()
    await loadBlockchainData()
  }, [])

  return (
    <div>
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
    </div>
  )
}

export default App
