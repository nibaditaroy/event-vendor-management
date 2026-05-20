const { Service, Vendor } = require('../models');

exports.getServices = async (req, res) => {
  try {
    const services = await Service.findAll({
      include: [{ model: Vendor, as: 'vendor', attributes: ['business_name'] }]
    });
    res.json({ success: true, data: services });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createService = async (req, res) => {
  try {
    const { title, description, price, thumbnail } = req.body;
    
    const vendor = await Vendor.findOne({ where: { user_id: req.user.id } });
    if (!vendor) return res.status(403).json({ success: false, message: 'Only vendors can create services' });

    const service = await Service.create({
      vendor_id: vendor.id,
      title,
      description,
      price,
      thumbnail
    });

    res.status(201).json({ success: true, data: service });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateService = async (req, res) => {
  try {
    const { title, description, price, thumbnail } = req.body;
    const service = await Service.findByPk(req.params.id);
    if (!service) return res.status(404).json({ success: false, message: 'Service not found' });

    const vendor = await Vendor.findOne({ where: { user_id: req.user.id } });
    if (service.vendor_id !== vendor.id) return res.status(403).json({ success: false, message: 'Unauthorized' });

    await service.update({ title, description, price, thumbnail });
    res.json({ success: true, data: service });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.deleteService = async (req, res) => {
  try {
    const service = await Service.findByPk(req.params.id);
    if (!service) return res.status(404).json({ success: false, message: 'Service not found' });

    const vendor = await Vendor.findOne({ where: { user_id: req.user.id } });
    if (service.vendor_id !== vendor.id) return res.status(403).json({ success: false, message: 'Unauthorized' });

    await service.destroy();
    res.json({ success: true, message: 'Service deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
