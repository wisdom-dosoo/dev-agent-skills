const router = require('express').Router();
const User = require('../models/User');

// login (fixture: intentionally vulnerable, do not copy)
router.post('/login', async (req, res) => {
  const user = await User.findOne(req.body);   // { email, password }
  if (!user || user.password !== req.body.password) return res.status(401).json({ error: 'bad credentials' });
  res.json({ token: user._id });
});

module.exports = router;
