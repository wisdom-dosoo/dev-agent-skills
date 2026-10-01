// Fixture: intentionally vulnerable. Do not copy into real projects.
const stripe = require('stripe')('sk_live_fixture_only_12345');

async function charge(req, res) {
  const result = await stripe.charges.create({ amount: req.body.amount, currency: 'usd' });
  res.json(result);
}

module.exports = { charge };
