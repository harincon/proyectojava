import { useState } from "react";
import Logo from "../components/Logo";
import { Btn, Badge, Card } from "../components/ui";

const FEATURED = [
  {
    id: 1,
    title: "Apartamento moderno en Chapinero",
    city: "Bogotá",
    neighborhood: "Chapinero Alto",
    price: "$ 520.000.000",
    modalidad: "venta",
    tipo: "Apartamento",
    beds: 3, baths: 2, area: 85,
    img: "https://images.unsplash.com/photo-1754999809963-79a41e8fb648?w=600&h=400&fit=crop&auto=format",
    tag: "Destacado",
  },
  {
    id: 2,
    title: "Casa familiar con jardín",
    city: "Medellín",
    neighborhood: "El Poblado",
    price: "$ 4.200.000/mes",
    modalidad: "arriendo",
    tipo: "Casa",
    beds: 4, baths: 3, area: 180,
    img: "https://images.unsplash.com/photo-1786462543687-26614deb2d6f?w=600&h=400&fit=crop&auto=format",
    tag: "Nuevo",
  },
  {
    id: 3,
    title: "Penthouse con vista panorámica",
    city: "Cali",
    neighborhood: "Ciudad Jardín",
    price: "$ 1.200.000.000",
    modalidad: "venta",
    tipo: "Penthouse",
    beds: 5, baths: 4, area: 320,
    img: "https://images.unsplash.com/photo-1782803432396-e168aa0e54a1?w=600&h=400&fit=crop&auto=format",
    tag: "Premium",
  },
  {
    id: 4,
    title: "Oficina corporativa central",
    city: "Bogotá",
    neighborhood: "Salitre",
    price: "$ 6.800.000/mes",
    modalidad: "arriendo",
    tipo: "Oficina",
    beds: 0, baths: 2, area: 120,
    img: "https://images.unsplash.com/photo-1780147343308-7ede77816ee6?w=600&h=400&fit=crop&auto=format",
    tag: "Disponible",
  },
  {
    id: 5,
    title: "Local comercial esquinero",
    city: "Barranquilla",
    neighborhood: "El Prado",
    price: "$ 890.000.000",
    modalidad: "venta",
    tipo: "Local",
    beds: 0, baths: 1, area: 65,
    img: "https://images.unsplash.com/photo-1789132782754-b89fe6c5c774?w=600&h=400&fit=crop&auto=format",
    tag: "Precio bajo",
  },
  {
    id: 6,
    title: "Apartaestudio amoblado Zona Rosa",
    city: "Bogotá",
    neighborhood: "Zona Rosa",
    price: "$ 2.100.000/mes",
    modalidad: "arriendo",
    tipo: "Apartaestudio",
    beds: 1, baths: 1, area: 42,
    img: "https://images.unsplash.com/photo-1757924461488-ef9ad0670978?w=600&h=400&fit=crop&auto=format",
    tag: "Amoblado",
  },
];

const STATS = [
  { value: "12.400+", label: "Propiedades activas" },
  { value: "380+", label: "Inmobiliarias aliadas" },
  { value: "28", label: "Ciudades" },
  { value: "94%", label: "Clientes satisfechos" },
];

interface HomeProps {
  onNavigate: (view: string, extra?: object) => void;
}

export default function Home({ onNavigate }: HomeProps) {
  const [ciudad, setCiudad] = useState("");
  const [tipo, setTipo] = useState("");
  const [modalidad, setModalidad] = useState("");

  return (
    <div className="min-h-screen bg-[#F7F2E8]">
      {/* ── Header ─────────────────────────────────────────── */}
      <header className="bg-[#243B32] sticky top-0 z-40">
        <div className="max-w-[1440px] mx-auto px-6 lg:px-12 h-16 flex items-center justify-between">
          <button onClick={() => onNavigate("home")} className="focus:outline-none">
            <Logo size="md" variant="light" />
          </button>
          <nav className="hidden md:flex items-center gap-7">
            <button onClick={() => onNavigate("catalog")} className="text-[#E8D8C4]/80 hover:text-[#F7F2E8] text-sm font-medium transition-colors">Propiedades</button>
            <button className="text-[#E8D8C4]/80 hover:text-[#F7F2E8] text-sm font-medium transition-colors">Inmobiliarias</button>
            <button className="text-[#E8D8C4]/80 hover:text-[#F7F2E8] text-sm font-medium transition-colors">¿Cómo funciona?</button>
          </nav>
          <div className="flex items-center gap-3">
            <Btn variant="ghost" size="sm" onClick={() => onNavigate("auth")} className="text-[#E8D8C4]/80 hover:text-[#F7F2E8] hover:bg-white/10">
              Iniciar sesión
            </Btn>
            <Btn size="sm" onClick={() => onNavigate("auth")}>Publicar gratis</Btn>
          </div>
        </div>
      </header>

      {/* ── Hero ──────────────────────────────────────────── */}
      <section className="relative bg-[#243B32] overflow-hidden">
        <div
          className="absolute inset-0 opacity-20"
          style={{
            backgroundImage: `url(https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=1440&h=700&fit=crop&auto=format)`,
            backgroundSize: "cover",
            backgroundPosition: "center",
          }}
        />
        <div className="absolute inset-0 bg-gradient-to-b from-[#243B32]/70 to-[#243B32]" />
        <div className="relative max-w-[1440px] mx-auto px-6 lg:px-12 pt-20 pb-16">
          <p className="text-[#83946A] text-sm font-medium tracking-widest uppercase mb-4">Plataforma inmobiliaria colombiana</p>
          <h1 className="font-display text-5xl lg:text-6xl font-semibold text-[#F7F2E8] leading-tight max-w-2xl mb-6">
            Encuentra el lugar <em className="italic text-[#C96E4B] not-italic">donde quieres</em> vivir
          </h1>
          <p className="text-[#E8D8C4]/70 text-lg max-w-xl mb-10">
            Explora miles de propiedades en venta y arriendo en las principales ciudades de Colombia.
          </p>

          {/* Search bar */}
          <div className="bg-[#F7F2E8] rounded-2xl p-4 lg:p-5 shadow-xl flex flex-col lg:flex-row gap-3 max-w-3xl">
            <div className="flex-1">
              <label className="text-xs text-[#6b7280] font-medium block mb-1.5">Ciudad</label>
              <select
                value={ciudad}
                onChange={e => setCiudad(e.target.value)}
                className="w-full bg-transparent text-[#252525] text-sm focus:outline-none cursor-pointer font-medium"
              >
                <option value="">Todas las ciudades</option>
                <option>Bogotá</option>
                <option>Medellín</option>
                <option>Cali</option>
                <option>Barranquilla</option>
                <option>Cartagena</option>
                <option>Bucaramanga</option>
              </select>
            </div>
            <div className="hidden lg:block w-px bg-[#ddd6c8]" />
            <div className="flex-1">
              <label className="text-xs text-[#6b7280] font-medium block mb-1.5">Tipo de inmueble</label>
              <select
                value={tipo}
                onChange={e => setTipo(e.target.value)}
                className="w-full bg-transparent text-[#252525] text-sm focus:outline-none cursor-pointer font-medium"
              >
                <option value="">Todos los tipos</option>
                <option>Apartamento</option>
                <option>Casa</option>
                <option>Oficina</option>
                <option>Local</option>
                <option>Bodega</option>
                <option>Lote</option>
              </select>
            </div>
            <div className="hidden lg:block w-px bg-[#ddd6c8]" />
            <div className="flex-1">
              <label className="text-xs text-[#6b7280] font-medium block mb-1.5">Modalidad</label>
              <select
                value={modalidad}
                onChange={e => setModalidad(e.target.value)}
                className="w-full bg-transparent text-[#252525] text-sm focus:outline-none cursor-pointer font-medium"
              >
                <option value="">Venta y arriendo</option>
                <option>Venta</option>
                <option>Arriendo</option>
              </select>
            </div>
            <Btn size="lg" onClick={() => onNavigate("catalog")} className="lg:self-end">
              <span>🔍</span> Buscar
            </Btn>
          </div>

          {/* Quick tags */}
          <div className="flex flex-wrap gap-2 mt-5">
            {["Apartamento en Bogotá", "Casa en Medellín", "Oficina en Cali", "Arriendo económico"].map(t => (
              <button
                key={t}
                onClick={() => onNavigate("catalog")}
                className="text-xs text-[#E8D8C4]/70 border border-[#E8D8C4]/20 rounded-full px-3 py-1.5 hover:bg-white/10 hover:text-[#E8D8C4] transition-colors"
              >
                {t}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* ── Stats ────────────────────────────────────────── */}
      <section className="bg-[#E8D8C4] border-b border-[#d6c4ab]">
        <div className="max-w-[1440px] mx-auto px-6 lg:px-12 py-8 grid grid-cols-2 lg:grid-cols-4 gap-6">
          {STATS.map(s => (
            <div key={s.label} className="text-center">
              <p className="font-display text-3xl font-semibold text-[#243B32]">{s.value}</p>
              <p className="text-sm text-[#6b7280] mt-1">{s.label}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── Featured properties ───────────────────────────── */}
      <section className="max-w-[1440px] mx-auto px-6 lg:px-12 py-16">
        <div className="flex items-end justify-between mb-10">
          <div>
            <p className="text-[#C96E4B] text-sm font-medium tracking-widest uppercase mb-2">Propiedades destacadas</p>
            <h2 className="font-display text-4xl font-semibold text-[#243B32]">Las más buscadas esta semana</h2>
          </div>
          <Btn variant="outline" onClick={() => onNavigate("catalog")}>Ver todas →</Btn>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {FEATURED.map(p => (
            <PropertyCard key={p.id} property={p} onNavigate={onNavigate} />
          ))}
        </div>
      </section>

      {/* ── CTA publish ────────────────────────────────────── */}
      <section className="bg-[#243B32] mx-6 lg:mx-12 mb-16 rounded-3xl overflow-hidden relative">
        <div
          className="absolute inset-0 opacity-10"
          style={{
            backgroundImage: `url(https://images.unsplash.com/photo-1564471925181-982d3a6c1a3f?w=1200&h=400&fit=crop&auto=format)`,
            backgroundSize: "cover",
            backgroundPosition: "center",
          }}
        />
        <div className="relative max-w-[1440px] mx-auto px-12 py-16 flex flex-col lg:flex-row items-center justify-between gap-8">
          <div>
            <p className="text-[#83946A] text-sm font-medium tracking-widest uppercase mb-3">Para inmobiliarias y propietarios</p>
            <h2 className="font-display text-4xl font-semibold text-[#F7F2E8] leading-tight">
              Publica tu propiedad<br />en minutos
            </h2>
            <p className="text-[#E8D8C4]/70 mt-4 max-w-md">
              Llega a miles de compradores y arrendatarios potenciales. Planes gratuitos y de pago disponibles para inmobiliarias y propietarios particulares.
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-3">
            <Btn size="lg" onClick={() => onNavigate("auth")}>Publicar ahora</Btn>
            <Btn variant="ghost" size="lg" className="text-[#E8D8C4]/80 hover:bg-white/10 hover:text-[#F7F2E8]">
              Ver planes
            </Btn>
          </div>
        </div>
      </section>

      {/* ── Cities ─────────────────────────────────────────── */}
      <section className="max-w-[1440px] mx-auto px-6 lg:px-12 py-16">
        <h2 className="font-display text-3xl font-semibold text-[#243B32] mb-8">Explora por ciudad</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
          {[
            { name: "Bogotá", count: "4.820 prop.", img: "photo-1545324418-cc1a3fa10c00" },
            { name: "Medellín", count: "2.640 prop.", img: "photo-1564471925181-982d3a6c1a3f" },
            { name: "Cali", count: "1.380 prop.", img: "photo-1565363887715-8884629e09ee" },
            { name: "Barranquilla", count: "980 prop.", img: "photo-1619218070141-bcfeb8b93074" },
            { name: "Cartagena", count: "720 prop.", img: "photo-1565953522043-baea26b83b7e" },
            { name: "Bucaramanga", count: "460 prop.", img: "photo-1515263487990-61b07816b324" },
          ].map(c => (
            <button
              key={c.name}
              onClick={() => onNavigate("catalog")}
              className="group relative rounded-2xl overflow-hidden aspect-square cursor-pointer"
            >
              <img
                src={`https://images.unsplash.com/${c.img}?w=300&h=300&fit=crop&auto=format`}
                alt={c.name}
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#243B32]/80 to-transparent" />
              <div className="absolute bottom-0 left-0 p-3">
                <p className="text-[#F7F2E8] font-semibold text-sm leading-tight">{c.name}</p>
                <p className="text-[#E8D8C4]/70 text-xs">{c.count}</p>
              </div>
            </button>
          ))}
        </div>
      </section>

      {/* ── Footer ─────────────────────────────────────────── */}
      <footer className="bg-[#243B32] mt-4">
        <div className="max-w-[1440px] mx-auto px-6 lg:px-12 py-12 grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="col-span-1 md:col-span-2">
            <Logo size="md" variant="light" />
            <p className="text-[#E8D8C4]/60 text-sm mt-4 max-w-xs">
              La plataforma inmobiliaria líder de Colombia. Conectamos propietarios, inmobiliarias y compradores de manera simple y segura.
            </p>
          </div>
          {[
            { title: "Explorar", links: ["Propiedades en venta", "Propiedades en arriendo", "Nuevos proyectos", "Mapa de propiedades"] },
            { title: "Empresa", links: ["Sobre nosotros", "Trabaja con nosotros", "Blog", "Contacto"] },
          ].map(col => (
            <div key={col.title}>
              <p className="text-[#F7F2E8] font-semibold text-sm mb-4">{col.title}</p>
              <ul className="space-y-2.5">
                {col.links.map(l => (
                  <li key={l}>
                    <a href="#" className="text-[#E8D8C4]/60 text-sm hover:text-[#E8D8C4] transition-colors">{l}</a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="border-t border-white/10 max-w-[1440px] mx-auto px-6 lg:px-12 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
          <p className="text-[#E8D8C4]/40 text-xs">© 2026 Habita Colombia. Todos los derechos reservados.</p>
          <div className="flex gap-4">
            {["Privacidad", "Términos", "Cookies"].map(l => (
              <a key={l} href="#" className="text-[#E8D8C4]/40 text-xs hover:text-[#E8D8C4]/70 transition-colors">{l}</a>
            ))}
          </div>
        </div>
      </footer>
    </div>
  );
}

function PropertyCard({ property: p, onNavigate }: { property: typeof FEATURED[0]; onNavigate: (v: string, e?: object) => void }) {
  const [liked, setLiked] = useState(false);
  return (
    <Card className="overflow-hidden group cursor-pointer hover:shadow-md transition-shadow" onClick={() => onNavigate("detail", { id: p.id })}>
      <div className="relative h-52 bg-[#E8D8C4] overflow-hidden">
        <img
          src={p.img}
          alt={p.title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
        />
        <div className="absolute top-3 left-3 flex gap-2">
          <Badge label={p.tag} variant="neutral" />
          <Badge label={p.modalidad === "venta" ? "Venta" : "Arriendo"} variant={p.modalidad === "venta" ? "venta" : "arriendo"} />
        </div>
        <button
          className={`absolute top-3 right-3 w-9 h-9 rounded-full flex items-center justify-center transition-all ${liked ? "bg-[#C96E4B] text-white" : "bg-white/90 text-[#6b7280] hover:text-[#C96E4B]"}`}
          onClick={e => { e.stopPropagation(); setLiked(!liked); }}
        >
          {liked ? "♥" : "♡"}
        </button>
      </div>
      <div className="p-5">
        <p className="font-display text-xl font-semibold text-[#C96E4B] mb-1">{p.price}</p>
        <h3 className="font-medium text-[#252525] leading-snug mb-1">{p.title}</h3>
        <p className="text-sm text-[#6b7280] mb-4">
          <span className="text-[#83946A]">📍</span> {p.neighborhood}, {p.city}
        </p>
        <div className="flex items-center gap-4 text-xs text-[#6b7280] border-t border-[#ddd6c8] pt-4">
          {p.beds > 0 && <span>🛏 {p.beds} hab.</span>}
          <span>🚿 {p.baths} baños</span>
          <span>📐 {p.area} m²</span>
          <span className="ml-auto text-[#83946A] font-medium">{p.tipo}</span>
        </div>
      </div>
    </Card>
  );
}
