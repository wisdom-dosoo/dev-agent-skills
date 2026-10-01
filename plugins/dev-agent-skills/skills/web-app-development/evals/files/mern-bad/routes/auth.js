const router = require('express').Router();
const User = require('../models/User');

// login
router.post('/login', async (req, res) => {
  const user = await User.findOne(req.body);   // { email, password }
  if (!user) return res.status(401).json({ error: 'bad credentials' });
  res.json({ token: user._id });
});

module.exports = router;
