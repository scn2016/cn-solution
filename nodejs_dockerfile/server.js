// server.js

const express = require('express')
const app = express()

app.get('/', (req, res) => {
    res.send('Hello Condenast, This is a Node.js app!')
})

app.listen(5000, () => {
    console.log('Server is up on 5000')
})
