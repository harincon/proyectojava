import { useState } from "react";
import Home from "./views/Home";
import Catalog from "./views/Catalog";
import PropertyDetail from "./views/PropertyDetail";
import Auth from "./views/Auth";
import ClientPanel from "./views/ClientPanel";
import AgencyPanel from "./views/AgencyPanel";
import AdminPanel from "./views/AdminPanel";

type View = "home" | "catalog" | "detail" | "auth" | "client" | "agency" | "admin";

export default function App() {
  const [view, setView] = useState<View>("home");
  const [, setExtra] = useState<object>({});

  function navigate(v: string, e?: object) {
    setView(v as View);
    if (e) setExtra(e);
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  const props = { onNavigate: navigate };

  return (
    <div className="min-h-screen">
      {/* Dev navigation ribbon */}
      <div className="fixed bottom-4 left-1/2 -translate-x-1/2 z-50 bg-[#243B32]/95 backdrop-blur-sm rounded-2xl px-4 py-2.5 flex items-center gap-1.5 shadow-xl border border-white/10 flex-wrap justify-center">
        <span className="text-[#83946A] text-xs font-medium mr-1 font-mono-custom">VISTAS:</span>
        {([
          ["home", "Inicio"],
          ["catalog", "Catálogo"],
          ["detail", "Propiedad"],
          ["auth", "Auth"],
          ["client", "Cliente"],
          ["agency", "Inmobiliaria"],
          ["admin", "Admin"],
        ] as const).map(([v, label]) => (
          <button
            key={v}
            onClick={() => navigate(v)}
            className={`px-3 py-1.5 rounded-xl text-xs font-medium transition-all ${view === v ? "bg-[#C96E4B] text-white" : "text-[#E8D8C4]/70 hover:text-[#E8D8C4] hover:bg-white/10"}`}
          >
            {label}
          </button>
        ))}
      </div>

      {view === "home" && <Home {...props} />}
      {view === "catalog" && <Catalog {...props} />}
      {view === "detail" && <PropertyDetail {...props} />}
      {view === "auth" && <Auth {...props} />}
      {view === "client" && <ClientPanel {...props} />}
      {view === "agency" && <AgencyPanel {...props} />}
      {view === "admin" && <AdminPanel {...props} />}
    </div>
  );
}
