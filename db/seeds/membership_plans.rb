# Create-only: prices are managed from the admin panel, so existing plans are never overwritten.
# Also loaded by the CreateMembershipPlans migration.

membership_plans_data = [
  {
    name: "Özel Ders 1",
    description: "Dövüş sporlarına giriş",
    monthly_price: 8_000,
    features: [
      "Haftada 2, ayda 8 özel ders",
      "Bire bir antrenör desteği",
      "Torba, interval ve ağırlık antrenmanları",
      "Antrenör eşliğinde teknik sparring"
    ]
  },
  {
    name: "Grup Dersleri",
    description: "Toplu antrenman yapmak isteyenlere",
    monthly_price: 2_500,
    featured: true,
    features: [
      "Haftada 2, ayda 8 grup dersi",
      "Profesyonel antrenörler eşliğinde",
      "Toplu antrenman programları",
      "Ekiple birlikte sparring"
    ]
  },
  {
    name: "Özel Ders 2",
    description: "Hızlı ilerlemek isteyenlere",
    monthly_price: 12_000,
    features: [
      "Haftada 3, ayda 12 özel ders",
      "Bire bir antrenör desteği",
      "Kişiselleştirilmiş antrenman programı",
      "Antrenör eşliğinde teknik sparring"
    ]
  }
]

membership_plans_data.each.with_index(1) do |attrs, position|
  MembershipPlan.find_or_create_by!(name: attrs[:name]) do |plan|
    plan.assign_attributes(attrs.except(:name))
    plan.position = position
  end
end
