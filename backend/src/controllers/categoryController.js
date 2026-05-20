const { Category } = require('../models');

exports.getCategories = async (req, res) => {
  try {
    const categories = await Category.findAll();
    
    // Filter unique by name (case-insensitive)
    const uniqueCategories = [];
    const seenNames = new Set();
    
    for (const cat of categories) {
      const name = (cat.name || '').toString().toLowerCase().trim();
      if (name && !seenNames.has(name)) {
        seenNames.add(name);
        uniqueCategories.push(cat);
      }
    }
    
    res.json({ success: true, data: uniqueCategories });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createCategory = async (req, res) => {
  try {
    const { name, icon } = req.body;
    const category = await Category.create({ name, icon });
    res.status(201).json({ success: true, data: category });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
