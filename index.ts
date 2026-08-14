/**
 * MAHARANI TRADERS — Cloud Functions (Phase 1 foundation)
 *
 * Phase 1 intentionally ships NO business-logic functions (no wallet,
 * voucher, order processing, etc.). This file only establishes the
 * trusted-backend architecture that later phases will build on:
 *   - Admin SDK initialization
 *   - A reusable "require caller has role X" guard for callable functions
 *   - Structured logging / structured errors
 *
 * Every later phase that needs a privileged write (changing a user's role,
 * approving a retailer, adjusting stock, etc.) should route through a
 * callable function that uses `requireRole` below — never trust a role
 * claim sent from the client.
 */

import * as admin from 'firebase-admin';
import { HttpsError, onCall, type CallableRequest } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';

admin.initializeApp();
const db = admin.firestore();

export const ROLES = {
  SUPER_ADMIN: 'super_admin',
  ADMIN: 'admin',
  STAFF: 'staff',
  SALESMAN: 'salesman',
  RETAILER: 'retailer',
} as const;

export type Role = (typeof ROLES)[keyof typeof ROLES];

/**
 * Reads the caller's Firestore profile and throws an HttpsError if they
 * are not authenticated, have no profile, are inactive, or do not hold
 * one of `allowedRoles`. Use at the top of every privileged callable
 * function added in later phases.
 */
export async function requireRole<T>(
  request: CallableRequest<T>,
  allowedRoles: Role[]
): Promise<{ uid: string; role: Role }> {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'You must be signed in.');
  }

  const snapshot = await db.collection('users').doc(uid).get();
  if (!snapshot.exists) {
    throw new HttpsError('permission-denied', 'No account found for this user.');
  }

  const data = snapshot.data()!;
  if (data.active !== true) {
    throw new HttpsError('permission-denied', 'This account is inactive.');
  }

  const role = data.role as Role;
  if (!allowedRoles.includes(role)) {
    throw new HttpsError('permission-denied', 'You do not have permission to perform this action.');
  }

  return { uid, role };
}

/**
 * Phase 1 smoke-test function only — confirms the Functions foundation
 * (Admin SDK init, role guard, deploy pipeline) actually works end to
 * end. Safe to remove once a real Phase 3+ function exists that proves
 * the same thing.
 */
export const ping = onCall(async (request) => {
  const { uid, role } = await requireRole(request, Object.values(ROLES) as Role[]);
  logger.info('ping called', { uid, role });
  return { ok: true, uid, role, serverTime: admin.firestore.Timestamp.now().toMillis() };
});
