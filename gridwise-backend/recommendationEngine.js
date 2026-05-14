const { db } = require('./firebaseAdmin');

/**
 * Motor de recomendaciones residenciales.
 * Evalua consumo y eventos IoT para generar sugerencias de ahorro.
 */
class RecommendationEngine {
  constructor() {
    this.rules = [
      {
        id: 'rule_high_instant_power',
        type: 'efficiency',
        condition: (data) => data.source === 'iot' && Number(data.payload.instant_power_watts || 0) > 1800,
        generate: (data) => ({
          message: 'Se detecto un pico alto de potencia instantanea. Considera escalonar equipos de alto consumo para evitar sobrecargas.',
          priority: 'high'
        }),
      },
      {
        id: 'rule_standby_drain',
        type: 'efficiency',
        condition: (data) => {
          const standby = Number(data.payload.standby_watts || 0);
          return data.source === 'manual' && standby >= 80;
        },
        generate: () => ({
          message: 'El consumo en espera es elevado. Usa regletas con interruptor o temporizadores para reducir energia fantasma.',
          priority: 'medium'
        }),
      },
      {
        id: 'rule_monthly_projection',
        type: 'cost',
        condition: (data) =>
          data.source === 'dashboard' &&
          Number(data.payload.projected_monthly_kwh || 0) > Number(data.payload.threshold_kwh || 500),
        generate: (data) => ({
          message: `Tu proyeccion mensual (${Number(data.payload.projected_monthly_kwh || 0).toFixed(1)} kWh) supera el umbral configurado. Ajusta horarios de climatizacion y lavanderia.`,
          priority: 'high'
        }),
      },
    ];
  }

  async processEvent(eventData) {
    try {
      console.log(`[Engine] Analizando evento: ${eventData.source}`);
      
      for (const rule of this.rules) {
        if (rule.condition(eventData)) {
          console.log(`[Engine] Regla activada: ${rule.id}`);
          const rec = rule.generate(eventData);
          
          const recommendationData = {
            type: rule.type,
            message: rec.message,
            priority: rec.priority,
            user_id: eventData.user_id,
            device_id: eventData.device_id || null,
            timestamp: new Date(),
            status: 'pending'
          };

          await db.collection('recommendations').add(recommendationData);
          console.log('[Engine] Recomendacion guardada');
        }
      }
    } catch (e) {
      console.error('[Engine] Error al procesar evento:', e);
    }
  }
}

module.exports = new RecommendationEngine();
