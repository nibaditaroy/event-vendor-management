const { Vendor, User, Category } = require('../models');
const { Op } = require('sequelize');

exports.getVendors = async (req, res) => {
  try {
    const { category_id, search } = req.query;
    const where = {};
    if (category_id) where.category_id = category_id;
    if (search) {
      where[Op.or] = [
        { business_name: { [Op.iLike]: `%${search}%` } },
        { description: { [Op.iLike]: `%${search}%` } }
      ];
    }

    const vendors = await Vendor.findAll({
      where,
      include: [
        { model: User, as: 'user', attributes: ['name', 'email', 'phone', 'profile_image'] },
        { model: Category, as: 'category', attributes: ['name', 'icon'] }
      ]
    });
    res.json({ success: true, data: vendors });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getVendorById = async (req, res) => {
  try {
    const vendor = await Vendor.findByPk(req.params.id, {
      include: [
        { model: User, as: 'user', attributes: ['name', 'email', 'phone', 'profile_image'] },
        { model: Category, as: 'category', attributes: ['name', 'icon'] },
        { model: require('../models').Service, as: 'services' }
      ]
    });
    if (!vendor) return res.status(404).json({ success: false, message: 'Vendor not found' });
    res.json({ success: true, data: vendor });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createVendorProfile = async (req, res) => {
  try {
    const { business_name, category_id, description, address } = req.body;
    
    // Check if vendor already has profile
    const existingVendor = await Vendor.findOne({ where: { user_id: req.user.id } });
    if (existingVendor) return res.status(400).json({ success: false, message: 'Vendor profile already exists' });

    const vendor = await Vendor.create({
      user_id: req.user.id,
      business_name,
      category_id,
      description,
      address,
      rating: 0,
      verified: false
    });

    res.status(201).json({ success: true, data: vendor });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getVendorProfile = async (req, res) => {
  try {
    const vendor = await Vendor.findOne({
      where: { user_id: req.user.id },
      include: [
        { model: User, as: 'user', attributes: ['name', 'email', 'phone', 'profile_image'] },
        { model: Category, as: 'category', attributes: ['name', 'icon'] }
      ]
    });
    if (!vendor) return res.status(404).json({ success: false, message: 'Vendor profile not found' });
    res.json({ success: true, data: vendor });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateVendorProfile = async (req, res) => {
  try {
    const { business_name, category_id, description, address, profile_image } = req.body;
    const vendor = await Vendor.findOne({ where: { user_id: req.user.id } });
    if (!vendor) return res.status(404).json({ success: false, message: 'Vendor profile not found' });

    await vendor.update({ business_name, category_id, description, address });

    if (profile_image) {
      await User.update({ profile_image }, { where: { id: req.user.id } });
    }

    res.json({ success: true, data: vendor });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
